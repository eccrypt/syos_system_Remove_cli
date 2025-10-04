package com.syos.service;

import java.util.List;

import com.syos.factory.BillItemFactory;
import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.model.Product;
import com.syos.model.ShelfStock;
import com.syos.repository.BillingRepository;
import com.syos.repository.ProductRepository;
import com.syos.repository.ShelfStockRepository;
import com.syos.strategy.DiscountPricingStrategy;
import com.syos.strategy.NoDiscountStrategy;

public class WebStoreBillingService {
    private final BillingRepository billingRepository;
    private final ProductRepository productRepository;
    private final ShelfStockRepository shelfStockRepository;
    private final BillItemFactory billItemFactory;
    private final StockService stockService;

    public WebStoreBillingService() {
        this.billingRepository = new BillingRepository();
        this.productRepository = new ProductRepository();
        this.shelfStockRepository = new ShelfStockRepository(productRepository);
        this.billItemFactory = new BillItemFactory(new DiscountPricingStrategy(new NoDiscountStrategy()));
        this.stockService = new StockService();
    }

    public BillItem addItemToBill(String productCode, int quantity) throws Exception {
        ShelfStock shelf = shelfStockRepository.findByCode(productCode);
        if (shelf == null) {
            throw new IllegalArgumentException("Product code not found on shelf.");
        }

        Product product = productRepository.findByCode(productCode);
        if (product == null) {
            throw new IllegalArgumentException("Product code not found.");
        }

        int availableNonExpiredStock = stockService.getAvailableNonExpiredStock(productCode);
        if (availableNonExpiredStock == 0) {
            throw new IllegalArgumentException("This product is expired or out of non-expired stock.");
        }

        if (quantity > availableNonExpiredStock) {
            throw new IllegalArgumentException("Insufficient non-expired stock. Available: " + availableNonExpiredStock);
        }

        return billItemFactory.create(product, quantity);
    }

    public Bill processPayment(List<BillItem> billItems, double cashTendered) throws Exception {
        if (billItems == null || billItems.isEmpty()) {
            throw new IllegalArgumentException("No items in bill.");
        }

        double totalDue = billItems.stream().mapToDouble(BillItem::getTotalPrice).sum();

        if (cashTendered < totalDue) {
            throw new IllegalArgumentException("Cash tendered is less than total due.");
        }

        int serialNumber = billingRepository.nextSerial();
        Bill bill = new Bill.BillBuilder(serialNumber, billItems).withCashTendered(cashTendered).build();

        billingRepository.save(bill);

        for (BillItem item : billItems) {
            stockService.removeQuantityFromShelf(item.getProduct().getCode(), item.getQuantity());
        }

        return billingRepository.findById(bill.getId());
    }

    public List<String> getAvailableProductCodes() {
        return shelfStockRepository.getAllProductCodes().stream()
            .filter(code -> stockService.getAvailableNonExpiredStock(code) > 0)
            .toList();
    }

    public Product getProductByCode(String code) {
        return productRepository.findByCode(code);
    }

    public double getTodaySalesTotal() {
        return billingRepository.getTodaySalesTotal();
    }
}