package com.test.async;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class AsyncLoadTest {

    private static final String BASE_URL = "http://localhost:8080/syos-billing-system";
    private static final int NUM_CLIENTS = 2;
    private static final int REQUESTS_PER_CLIENT = 10;
    private static final int DELAY_BETWEEN_REQUESTS_MS = 50;

    public static void main(String[] args) {
        System.out.println("Starting Async Load Test...");
        System.out.println("Simulating " + NUM_CLIENTS + " clients sending " + REQUESTS_PER_CLIENT + " requests each");

        ExecutorService clientExecutor = Executors.newFixedThreadPool(NUM_CLIENTS);
        AtomicInteger totalRequests = new AtomicInteger(0);
        AtomicInteger successfulRequests = new AtomicInteger(0);
        AtomicInteger failedRequests = new AtomicInteger(0);

        long startTime = System.currentTimeMillis();

        // Start multiple clients
        for (int clientId = 1; clientId <= NUM_CLIENTS; clientId++) {
            final int finalClientId = clientId;
            clientExecutor.submit(() -> runClient(finalClientId, totalRequests, successfulRequests, failedRequests));
        }

        clientExecutor.shutdown();
        try {
            clientExecutor.awaitTermination(60, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        long endTime = System.currentTimeMillis();
        long totalTime = endTime - startTime;

        System.out.println("\nLoad Test Results");
        System.out.println("Total time: " + totalTime + "ms");
        System.out.println("Total requests: " + totalRequests.get());
        System.out.println("Successful requests: " + successfulRequests.get());
        System.out.println("Failed requests: " + failedRequests.get());
        System.out.println("Requests per second: " + (totalRequests.get() / (totalTime / 1000.0)));
    }

    private static void runClient(int clientId, AtomicInteger totalRequests,
                                AtomicInteger successfulRequests, AtomicInteger failedRequests) {
        System.out.println("Client " + clientId + " starting...");

        for (int i = 1; i <= REQUESTS_PER_CLIENT; i++) {
            try {
                sendRequest(clientId, i, totalRequests, successfulRequests, failedRequests);

                // Small delay between requests to simulate rapid succession
                Thread.sleep(DELAY_BETWEEN_REQUESTS_MS);

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }

        System.out.println("Client " + clientId + " finished.");
    }

    private static void sendRequest(int clientId, int requestNum, AtomicInteger totalRequests,
                                  AtomicInteger successfulRequests, AtomicInteger failedRequests) {
        totalRequests.incrementAndGet();

        try {
            URL url = new URL(BASE_URL + "/async-billing");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(30000);

            // Send request data
            String requestData = "action=processBill&billData=TestBill_Client" + clientId + "_Req" + requestNum;
            try (OutputStream os = conn.getOutputStream()) {
                os.write(requestData.getBytes());
                os.flush();
            }

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                // Read response
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    System.out.println("Client " + clientId + " Request " + requestNum + ": SUCCESS");
                    successfulRequests.incrementAndGet();
                }
            } else {
                System.out.println("Client " + clientId + " Request " + requestNum + ": HTTP " + responseCode);
                failedRequests.incrementAndGet();
            }

            conn.disconnect();

        } catch (IOException e) {
            System.out.println("Client " + clientId + " Request " + requestNum + ": FAILED - " + e.getMessage());
            failedRequests.incrementAndGet();
        }
    }
}