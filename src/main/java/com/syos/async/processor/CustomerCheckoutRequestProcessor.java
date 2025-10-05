package com.syos.async.processor;

import com.syos.async.AsyncRequest;
import com.syos.async.AsyncResponse;
import com.syos.async.RequestProcessor;
import com.syos.factory.BillItemFactory;
import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.repository.BillingRepository;
import com.syos.service.ProductService;
import com.syos.service.StockService;
import com.syos.strategy.DiscountPricingStrategy;
import com.syos.strategy.NoDiscountStrategy;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CustomerCheckoutRequestProcessor implements RequestProcessor {

    private final BillingRepository billingRepository;
    private final StockService stockService;
    private final ProductService productService;
    private final BillItemFactory billItemFactory;

    public CustomerCheckoutRequestProcessor() {
        this.billingRepository = new BillingRepository();
        this.stockService = new StockService();
        this.productService = new ProductService();
        this.billItemFactory = new BillItemFactory(new DiscountPricingStrategy(new NoDiscountStrategy()));
    }

    @Override
    public String getRequestType() {
        return "CUSTOMER_CHECKOUT";
    }

    @Override
    public AsyncResponse process(AsyncRequest request) {
        long startTime = System.currentTimeMillis();

        try {
            Map<String, Object> params = request.getParameters();
            String action = (String) params.get("action");

            switch (action) {
                case "PROCESS_CHECKOUT":
                    return processCustomerCheckout(request, params, startTime);
                default:
                    return AsyncResponse.error(request.getRequestId(),
                        "Unknown customer checkout action: " + action).processingTime(System.currentTimeMillis() - startTime).build();
            }

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Customer checkout processing error: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }

    private AsyncResponse processCustomerCheckout(AsyncRequest request, Map<String, Object> params, long startTime) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Integer> cart = (Map<String, Integer>) params.get("cart");

            if (cart == null || cart.isEmpty()) {
                return AsyncResponse.error(request.getRequestId(),
                    "Cart is empty").processingTime(System.currentTimeMillis() - startTime).build();
            }

            // Create bill items from cart
            List<BillItem> billItems = new ArrayList<>();
            double total = 0;

            for (Map.Entry<String, Integer> entry : cart.entrySet()) {
                String productCode = entry.getKey();
                int quantity = entry.getValue();

                var product = productService.findProductByCode(productCode);
                if (product != null) {
                    BillItem item = billItemFactory.create(product, quantity);
                    billItems.add(item);
                    total += item.getTotalPrice();
                }
            }

            if (billItems.isEmpty()) {
                return AsyncResponse.error(request.getRequestId(),
                    "No valid items in cart").processingTime(System.currentTimeMillis() - startTime).build();
            }

            // Create bill
            int serialNumber = billingRepository.nextSerial();
            Bill bill = new Bill.BillBuilder(serialNumber, billItems)
                    .withCashTendered(total)
                    .withTransactionType("ONLINE")
                    .build();

            // Save bill to database
            billingRepository.save(bill);

            // Deduct from online stock
            for (BillItem item : billItems) {
                stockService.deductFromOnline(item.getProduct().getCode(), item.getQuantity());
            }

            // Simulate processing time
            Thread.sleep(100);

            return AsyncResponse.success(request.getRequestId(),
                Map.of("status", "processed",
                       "billId", bill.getId(),
                       "serialNumber", bill.getSerialNumber(),
                       "totalAmount", bill.getTotalAmount(),
                       "cashTendered", bill.getCashTendered(),
                       "change", bill.getChangeReturned(),
                       "transactionType", bill.getTransactionType()))
                .processingTime(System.currentTimeMillis() - startTime).build();

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Customer checkout failed: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }
}