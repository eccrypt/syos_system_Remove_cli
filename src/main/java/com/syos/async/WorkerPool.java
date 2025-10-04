package com.syos.async;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.ArrayList;

public class WorkerPool {
    private final ExecutorService executorService;
    private final List<RequestProcessor> processors;
    private final RequestQueue requestQueue;
    private volatile boolean running = true;

    public WorkerPool(int poolSize, RequestQueue requestQueue, List<RequestProcessor> processors) {
        this.executorService = Executors.newFixedThreadPool(poolSize);
        this.requestQueue = requestQueue;
        this.processors = new ArrayList<>(processors);

        for (int i = 0; i < poolSize; i++) {
            executorService.submit(new Worker(i));
        }
    }
    public boolean submitRequest(AsyncRequest request) {
        return requestQueue.offer(request);
    }

    public boolean submitRequest(AsyncRequest request, long timeout) throws InterruptedException {
        return requestQueue.offer(request, timeout);
    }

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

    public int getActiveCount() {
        return ((java.util.concurrent.ThreadPoolExecutor) executorService).getActiveCount();
    }

    public int getQueueSize() {
        return requestQueue.size();
    }

    public boolean isRunning() {
        return running && !executorService.isShutdown();
    }

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
                    AsyncRequest request = requestQueue.poll(1000); 

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