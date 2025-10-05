package com.syos.Controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.syos.async.processor.CustomerCheckoutRequestProcessor;
import com.syos.async.AsyncRequest;
import com.syos.async.AsyncResponse;

@WebServlet(urlPatterns = "/async-customer-checkout")
public class AsyncCustomerCheckoutServlet extends HttpServlet {
    private final CustomerCheckoutRequestProcessor processor = new CustomerCheckoutRequestProcessor();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("AsyncCustomerCheckoutServlet: Received POST request");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String action = request.getParameter("action");
            System.out.println("AsyncCustomerCheckoutServlet: Action = " + action);

            if ("processCheckout".equals(action)) {
                handleCheckoutProcessing(request, response);
            } else {
                System.out.println("AsyncCustomerCheckoutServlet: Unknown action: " + action);
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Unknown action\"}");
            }
        } catch (Exception e) {
            System.err.println("AsyncCustomerCheckoutServlet: Exception: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    private void handleCheckoutProcessing(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        System.out.println("AsyncCustomerCheckoutServlet: Handling checkout processing");

        HttpSession session = request.getSession();
        @SuppressWarnings("unchecked")
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");

        System.out.println("AsyncCustomerCheckoutServlet: Cart = " + cart);

        if (cart == null || cart.isEmpty()) {
            System.out.println("AsyncCustomerCheckoutServlet: Cart is empty");
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Cart is empty\"}");
            return;
        }

        try {
            // Create async request and process synchronously for now
            Map<String, Object> params = new HashMap<>();
            params.put("action", "PROCESS_CHECKOUT");
            params.put("cart", new HashMap<>(cart)); // Pass a copy of the cart

            System.out.println("AsyncCustomerCheckoutServlet: Creating async request");
            AsyncRequest asyncRequest = new AsyncRequest("test-request", "CUSTOMER_CHECKOUT", params);

            System.out.println("AsyncCustomerCheckoutServlet: Processing request");
            AsyncResponse asyncResponse = processor.process(asyncRequest);

            System.out.println("AsyncCustomerCheckoutServlet: Response success = " + asyncResponse.isSuccess());

            if (asyncResponse.isSuccess()) {
                // Clear cart on successful checkout
                session.removeAttribute("cart");
                System.out.println("AsyncCustomerCheckoutServlet: Checkout successful, cart cleared");

                @SuppressWarnings("unchecked")
                Map<String, Object> data = (Map<String, Object>) asyncResponse.getData();
                String jsonData = String.format("{\"billId\":%d,\"serialNumber\":\"%s\",\"totalAmount\":%.2f,\"cashTendered\":%.2f,\"change\":%.2f,\"transactionType\":\"%s\"}",
                    data.get("billId"), data.get("serialNumber"), data.get("totalAmount"),
                    data.get("cashTendered"), data.get("change"), data.get("transactionType"));

                response.getWriter().write("{\"status\": \"success\", \"data\": " + jsonData + ", \"processingTime\": " +
                    asyncResponse.getProcessingTime() + "}");
            } else {
                System.out.println("AsyncCustomerCheckoutServlet: Checkout failed: " + asyncResponse.getErrorMessage());
                response.getWriter().write("{\"status\": \"error\", \"message\": \"" +
                    asyncResponse.getErrorMessage() + "\"}");
            }
        } catch (Exception e) {
            System.err.println("AsyncCustomerCheckoutServlet: Exception in processing: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Processing error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.getWriter().write("{\"status\": \"ok\", \"message\": \"Async customer checkout servlet is running\"}");
    }
}