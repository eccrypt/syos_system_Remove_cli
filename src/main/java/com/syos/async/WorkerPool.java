package com.syos.async;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.ArrayList;

/**
 * Manages a pool of worker threads that process asynchronous requests
 */
public class WorkerPool {
    private final ExecutorService executorService;
    private final List<RequestProcessor> processors;
    private final RequestQueue requestQueue;
    private volatile boolean running = true;

    public WorkerPool(int poolSize, RequestQueue requestQueue, List<RequestProcessor> processors) {
        this.executorService = Executors.newFixedThreadPool(poolSize);
        this.requestQueue = requestQueue;
        this.processors = new ArrayList<>(processors);

        // Start worker threads
        for (int i = 0; i < poolSize; i++) {
            executorService.submit(new Worker(i));
        }
    }

    /**
     * Submit a request for processing
     */
    public boolean submitRequest(AsyncRequest request) {
        return requestQueue.offer(request);
    }

    /**
     * Submit a request with timeout
     */
    public boolean submitRequest(AsyncRequest request, long timeout) throws InterruptedException {
        return requestQueue.offer(request, timeout);
    }

    /**
     * Shutdown the worker pool
     */
    public void shutdown() {
        running = false;
        executorService.shutdown();
        try {
            if (!executorService.awaitTermination(30, TimeUnit.SECONDS)) {
                executorService.shutdownNow();
            }
        } catch (InterruptedException e) {
            executorService.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }

    /**
     * Get the number of active threads
     */
    public int getActiveCount() {
        // This is a simplified implementation
        // In a real implementation, you'd track active workers
        return ((java.util.concurrent.ThreadPoolExecutor) executorService).getActiveCount();
    }

    /**
     * Get queue size
     */
    public int getQueueSize() {
        return requestQueue.size();
    }

    /**
     * Check if pool is running
     */
    public boolean isRunning() {
        return running && !executorService.isShutdown();
    }

    /**
     * Worker thread that processes requests
     */
    private class Worker implements Runnable {
        private final int workerId;

        public Worker(int workerId) {
            this.workerId = workerId;
        }

        @Override
        public void run() {
            System.out.println("Worker " + workerId + " started");

            while (running && !Thread.currentThread().isInterrupted()) {
                try {
                    // Poll for requests with a timeout
                    AsyncRequest request = requestQueue.poll(1000); // 1 second timeout

                    if (request != null) {
                        processRequest(request);
                    }

                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    System.err.println("Worker " + workerId + " encountered error: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            System.out.println("Worker " + workerId + " stopped");
        }

        private void processRequest(AsyncRequest request) {
            long startTime = System.currentTimeMillis();

            try {
                // Find the appropriate processor
                RequestProcessor processor = findProcessor(request.getRequestType());

                if (processor != null) {
                    AsyncResponse response = processor.process(request);
                    request.complete(response);
                    System.out.println("Processed request " + request.getRequestId() + " in " +
                                     (System.currentTimeMillis() - startTime) + "ms");
                } else {
                    request.completeExceptionally(new IllegalArgumentException(
                        "No processor found for request type: " + request.getRequestType()));
                }

            } catch (Exception e) {
                System.err.println("Error processing request " + request.getRequestId() + ": " + e.getMessage());
                request.completeExceptionally(e);
            }
        }

        private RequestProcessor findProcessor(String requestType) {
            for (RequestProcessor processor : processors) {
                if (processor.canHandle(requestType)) {
                    return processor;
                }
            }
            return null;
        }
    }
}