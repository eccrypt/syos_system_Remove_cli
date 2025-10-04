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

import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.model.Product;
import com.syos.service.WebStoreBillingService;

@WebServlet("/billing")
public class StoreBillingServlet extends HttpServlet {
    private final WebStoreBillingService billingService;

    public StoreBillingServlet() {
        this.billingService = new WebStoreBillingService();
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

        List<String> productCodes = billingService.getAvailableProductCodes();
        List<Product> products = new ArrayList<>();
        for (String code : productCodes) {
            Product product = billingService.getProductByCode(code);
            if (product != null) {
                products.add(product);
            }
        }
        request.setAttribute("products", products);

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

            BillItem item = billingService.addItemToBill(productCode, quantity);
            billItems.add(item);
            request.setAttribute("message", "Added " + quantity + " x " + item.getProduct().getName());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid quantity.");
        } catch (Exception e) {
            request.setAttribute("error", "Error adding product: " + e.getMessage());
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

            Bill savedBill = billingService.processPayment(billItems, cashTendered);

            // Clear session
            session.removeAttribute("billItems");

            request.setAttribute("bill", savedBill);
            request.getRequestDispatcher("/billReceipt.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid cash amount.");
            doGet(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error processing payment: " + e.getMessage());
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