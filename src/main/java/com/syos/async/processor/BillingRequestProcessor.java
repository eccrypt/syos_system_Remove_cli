package com.syos.async.processor;

import com.syos.async.AsyncRequest;
import com.syos.async.AsyncResponse;
import com.syos.async.RequestProcessor;
import com.syos.service.WebStoreBillingService;

import java.util.Map;

public class BillingRequestProcessor implements RequestProcessor {

    private final WebStoreBillingService billingService;

    public BillingRequestProcessor() {
        this.billingService = new WebStoreBillingService();
    }

    @Override
    public String getRequestType() {
        return "BILLING";
    }

    @Override
    public AsyncResponse process(AsyncRequest request) {
        long startTime = System.currentTimeMillis();

        try {
            Map<String, Object> params = request.getParameters();
            String action = (String) params.get("action");

            switch (action) {
                case "PROCESS_BILL":
                    return processBill(request, params, startTime);
                case "GET_BILL_HISTORY":
                    return getBillHistory(request, params, startTime);
                default:
                    return AsyncResponse.error(request.getRequestId(),
                        "Unknown billing action: " + action).processingTime(System.currentTimeMillis() - startTime).build();
            }

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Billing processing error: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }

    private AsyncResponse processBill(AsyncRequest request, Map<String, Object> params, long startTime) {
        try {
            java.util.List<com.syos.model.BillItem> billItems = (java.util.List<com.syos.model.BillItem>) params.get("billItems");
            Double cashTendered = (Double) params.get("cashTendered");

            if (billItems == null || billItems.isEmpty()) {
                return AsyncResponse.error(request.getRequestId(),
                    "No bill items provided").processingTime(System.currentTimeMillis() - startTime).build();
            }
            com.syos.model.Bill bill = billingService.processPayment(billItems, cashTendered);

            Thread.sleep(50);

            return AsyncResponse.success(request.getRequestId(),
                Map.of("status", "processed",
                       "billId", bill.getId(),
                       "serialNumber", bill.getSerialNumber(),
                       "totalAmount", bill.getTotalAmount(),
                       "cashTendered", bill.getCashTendered(),
                       "change", bill.getChangeReturned()))
                .processingTime(System.currentTimeMillis() - startTime).build();

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Bill processing failed: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }

    private AsyncResponse getBillHistory(AsyncRequest request, Map<String, Object> params, long startTime) {
        try {
            return AsyncResponse.success(request.getRequestId(),
                Map.of("bills", java.util.List.of(), "total", 0))
                .processingTime(System.currentTimeMillis() - startTime).build();

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Failed to get bill history: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }
}