package com.syos.async.processor;

import com.syos.async.AsyncRequest;
import com.syos.async.AsyncResponse;
import com.syos.async.RequestProcessor;
import com.syos.service.StoreBillingService;

import java.util.List;
import java.util.Map;

/**
 * Processor for billing-related asynchronous requests
 */
public class BillingRequestProcessor implements RequestProcessor {

    private final StoreBillingService billingService;

    public BillingRequestProcessor() {
        this.billingService = new StoreBillingService();
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
            // Extract bill processing parameters
            @SuppressWarnings("unchecked")
            java.util.List<com.syos.model.BillItem> billItems = (java.util.List<com.syos.model.BillItem>) params.get("billItems");
            Double cashTendered = (Double) params.get("cashTendered");
            Double totalDue = (Double) params.get("totalDue");

            if (billItems == null || billItems.isEmpty()) {
                return AsyncResponse.error(request.getRequestId(),
                    "No bill items provided").processingTime(System.currentTimeMillis() - startTime).build();
            }

            // Generate bill serial number and create bill
            com.syos.repository.BillingRepository billRepository = new com.syos.repository.BillingRepository();
            int serialNumber = billRepository.nextSerial();

            com.syos.model.Bill bill = new com.syos.model.Bill.BillBuilder(serialNumber, billItems)
                .withCashTendered(cashTendered)
                .build();

            // Save bill to database
            billRepository.save(bill);

            // Deduct from inventory
            com.syos.singleton.InventoryManager inventoryManager =
                com.syos.singleton.InventoryManager.getInstance(new com.syos.strategy.ExpiryAwareFifoStrategy());

            for (com.syos.model.BillItem item : billItems) {
                inventoryManager.deductFromShelf(item.getProduct().getCode(), item.getQuantity());
            }

            // Simulate additional processing time
            Thread.sleep(50);

            return AsyncResponse.success(request.getRequestId(),
                Map.of("status", "processed",
                       "billId", "BILL-" + serialNumber,
                       "serialNumber", serialNumber,
                       "totalAmount", totalDue,
                       "cashTendered", cashTendered,
                       "change", cashTendered - totalDue))
                .processingTime(System.currentTimeMillis() - startTime).build();

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Bill processing failed: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }

    private AsyncResponse getBillHistory(AsyncRequest request, Map<String, Object> params, long startTime) {
        try {
            String userId = (String) params.get("userId");

            // Get bill history for user
            // This is a simplified example

            return AsyncResponse.success(request.getRequestId(),
                Map.of("bills", java.util.List.of(), "total", 0))
                .processingTime(System.currentTimeMillis() - startTime).build();

        } catch (Exception e) {
            return AsyncResponse.error(request.getRequestId(),
                "Failed to get bill history: " + e.getMessage()).processingTime(System.currentTimeMillis() - startTime).build();
        }
    }
}