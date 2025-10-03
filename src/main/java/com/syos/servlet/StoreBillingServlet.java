package com.syos.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.syos.factory.BillItemFactory;
import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.model.Product;
import com.syos.model.ShelfStock;
import com.syos.repository.BillingRepository;
import com.syos.repository.ProductRepository;
import com.syos.repository.ShelfStockRepository;
import com.syos.singleton.InventoryManager;
import com.syos.strategy.DiscountPricingStrategy;
import com.syos.strategy.ExpiryAwareFifoStrategy;
import com.syos.strategy.NoDiscountStrategy;
import com.syos.util.CommonVariables;

@WebServlet("/billing")
public class StoreBillingServlet extends HttpServlet {
    private final BillingRepository billRepository = new BillingRepository();
    private final ProductRepository productRepository = new ProductRepository();
    private final ShelfStockRepository shelfStockRepository = new ShelfStockRepository(productRepository);
    private final BillItemFactory billItemFactory = new BillItemFactory(
            new DiscountPricingStrategy(new NoDiscountStrategy()));
    private final InventoryManager inventoryManager;

    public StoreBillingServlet() {
        // Ensure InventoryManager singleton is initialized with strategy
        this.inventoryManager = InventoryManager.getInstance(new ExpiryAwareFifoStrategy());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<BillItem> billItems = (List<BillItem>) session.getAttribute("billItems");
        if (billItems == null) {
            billItems = new ArrayList<>();
            session.setAttribute("billItems", billItems);
        }

        request.setAttribute("billItems", billItems);
        request.getRequestDispatcher("/billing.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addItem(request, response);
        } else if ("pay".equals(action)) {
            processPayment(request, response);
        } else if ("newBill".equals(action)) {
            newBill(request, response);
        } else {
            response.sendRedirect("billing");
        }
    }

    private void addItem(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<BillItem> billItems = (List<BillItem>) session.getAttribute("billItems");
        if (billItems == null) {
            billItems = new ArrayList<>();
            session.setAttribute("billItems", billItems);
        }

        String productCode = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");

        try {
            int quantity = Integer.parseInt(quantityStr);
            if (quantity <= 0) {
                request.setAttribute("error", "Quantity must be positive.");
                doGet(request, response);
                return;
            }

            ShelfStock shelf = shelfStockRepository.findByCode(productCode);
            if (shelf == null) {
                request.setAttribute("error", "Product code not found on shelf.");
                doGet(request, response);
                return;
            }

            Product product = productRepository.findByCode(productCode);
            if (product == null) {
                request.setAttribute("error", "Product code not found.");
                doGet(request, response);
                return;
            }

            int availableStock = inventoryManager.getAvailableStock(productCode);
            if (availableStock == 0) {
                request.setAttribute("error", "Product out of stock.");
                doGet(request, response);
                return;
            }

            if (quantity > availableStock) {
                request.setAttribute("error", "Insufficient stock. Available: " + availableStock);
                doGet(request, response);
                return;
            }

            BillItem item = billItemFactory.create(product, quantity);
            billItems.add(item);
            request.setAttribute("message", "Added " + quantity + " x " + item.getProduct().getName());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid quantity.");
        } catch (Exception e) {
            request.setAttribute("error", "Error adding product.");
        }

        doGet(request, response);
    }

    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        List<BillItem> billItems = (List<BillItem>) session.getAttribute("billItems");

        if (billItems == null || billItems.isEmpty()) {
            request.setAttribute("error", "No items in bill.");
            doGet(request, response);
            return;
        }

        String cashStr = request.getParameter("cashTendered");
        try {
            double cashTendered = Double.parseDouble(cashStr);
            double totalDue = billItems.stream().mapToDouble(BillItem::getTotalPrice).sum();

            if (cashTendered < totalDue) {
                request.setAttribute("error", "Cash tendered is less than total due.");
                doGet(request, response);
                return;
            }

            int serialNumber = billRepository.nextSerial();
            Bill bill = new Bill.BillBuilder(serialNumber, billItems).withCashTendered(cashTendered).build();

            billRepository.save(bill);

            for (BillItem item : billItems) {
                inventoryManager.deductFromShelf(item.getProduct().getCode(), item.getQuantity());
            }

            request.setAttribute("bill", bill);
            session.removeAttribute("billItems");
            request.getRequestDispatcher("/billReceipt.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid cash amount.");
            doGet(request, response);
        }
    }

    private void newBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        session.removeAttribute("billItems");
        response.sendRedirect("billing");
    }
}