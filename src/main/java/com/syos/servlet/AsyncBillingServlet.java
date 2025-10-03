package com.syos.servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.async.AsyncProcessorManager;
import com.syos.async.AsyncResponse;

@WebServlet("/async-billing")
public class AsyncBillingServlet extends HttpServlet {
    private final AsyncProcessorManager asyncManager = AsyncProcessorManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("processBill".equals(action)) {
            handleAsyncBillProcessing(request, response);
        } else if ("getBillHistory".equals(action)) {
            handleAsyncBillHistory(request, response);
        } else {
            response.getWriter().write("{\"error\": \"Unknown action\"}");
        }
    }

    private void handleAsyncBillProcessing(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Map<String, Object> params = new HashMap<>();
        params.put("action", "PROCESS_BILL");
        params.put("billData", request.getParameter("billData"));
        params.put("userId", request.getSession().getAttribute("userId"));

        CompletableFuture<AsyncResponse> future = asyncManager.submitRequest("BILLING", params);

        future.thenAccept(asyncResponse -> {
            try {
                response.setContentType("application/json");
                if (asyncResponse.isSuccess()) {
                    response.getWriter().write("{\"status\": \"success\", \"data\": " +
                        asyncResponse.getData() + ", \"processingTime\": " +
                        asyncResponse.getProcessingTime() + "}");
                } else {
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"" +
                        asyncResponse.getErrorMessage() + "\"}");
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        try {
            future.get(); 
        } catch (Exception e) {
            response.getWriter().write("{\"error\": \"Processing failed: " + e.getMessage() + "\"}");
        }
    }

    private void handleAsyncBillHistory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Prepare request parameters
        Map<String, Object> params = new HashMap<>();
        params.put("action", "GET_BILL_HISTORY");
        params.put("userId", request.getSession().getAttribute("userId"));

        // Submit async request
        CompletableFuture<AsyncResponse> future = asyncManager.submitRequest("BILLING", params);

        // Handle response
        try {
            AsyncResponse asyncResponse = future.get(); // Blocking for demo
            response.setContentType("application/json");

            if (asyncResponse.isSuccess()) {
                response.getWriter().write("{\"status\": \"success\", \"data\": " +
                    asyncResponse.getData() + ", \"processingTime\": " +
                    asyncResponse.getProcessingTime() + "}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"" +
                    asyncResponse.getErrorMessage() + "\"}");
            }
        } catch (Exception e) {
            response.getWriter().write("{\"error\": \"Processing failed: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Return queue statistics
        AsyncProcessorManager.QueueStats stats = asyncManager.getQueueStats();
        response.setContentType("application/json");
        response.getWriter().write(String.format(
            "{\"queueSize\": %d, \"remainingCapacity\": %d, \"activeWorkers\": %d, \"isRunning\": %s}",
            stats.queueSize, stats.remainingCapacity, stats.activeWorkers, stats.isRunning));
    }
}