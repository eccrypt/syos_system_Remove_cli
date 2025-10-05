package com.syos.Controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
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
import com.syos.repository.BillingRepository;
import com.syos.service.ProductService;
import com.syos.service.StockService;
import com.syos.strategy.DiscountPricingStrategy;
import com.syos.strategy.NoDiscountStrategy;

@WebServlet("/checkout")
public class CustomerCheckoutServlet extends HttpServlet {
    private final ProductService productService = new ProductService();
    private final BillingRepository billingRepository = new BillingRepository();
    private final StockService stockService = new StockService();
    private final BillItemFactory billItemFactory = new BillItemFactory(new DiscountPricingStrategy(new NoDiscountStrategy()));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }

        // Calculate total and prepare bill items
        List<BillItem> billItems = new ArrayList<>();
        double total = 0;

        for (Map.Entry<String, Integer> entry : cart.entrySet()) {
            Product product = productService.findProductByCode(entry.getKey());
            if (product != null) {
                BillItem item = billItemFactory.create(product, entry.getValue());
                billItems.add(item);
                total += item.getTotalPrice();
            }
        }

        request.setAttribute("billItems", billItems);
        request.setAttribute("total", total);
        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }

        // Calculate bill items and total
        List<BillItem> billItems = new ArrayList<>();
        double total = 0;

        for (Map.Entry<String, Integer> entry : cart.entrySet()) {
            Product product = productService.findProductByCode(entry.getKey());
            if (product != null) {
                BillItem item = billItemFactory.create(product, entry.getValue());
                billItems.add(item);
                total += item.getTotalPrice();
            }
        }

        try {
            // Create bill for customer checkout
            int serialNumber = billingRepository.nextSerial();
            Bill bill = new Bill.BillBuilder(serialNumber, billItems)
                    .withCashTendered(total)
                    .withTransactionType("ONLINE")
                    .build();

            // Save bill to database
            billingRepository.save(bill);

            // Deduct from online stock instead of shelf
            for (BillItem item : billItems) {
                stockService.deductFromOnline(item.getProduct().getCode(), item.getQuantity());
            }

            session.removeAttribute("cart"); // Clear cart

            request.setAttribute("bill", bill);
            request.getRequestDispatcher("/customerBillReceipt.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Checkout failed: " + e.getMessage());
            doGet(request, response);
        }
    }
}