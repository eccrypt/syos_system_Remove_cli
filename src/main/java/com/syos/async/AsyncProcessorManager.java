package com.syos.async;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

public class AsyncProcessorManager {
    private static AsyncProcessorManager instance;

    private final WorkerPool workerPool;
    private final RequestQueue requestQueue;

    private AsyncProcessorManager() {
        int queueCapacity = 1000;
        int poolSize = Math.max(2, Runtime.getRuntime().availableProcessors() / 2);
        this.requestQueue = new RequestQueue(queueCapacity);
        List<RequestProcessor> processors = List.of(
            new com.syos.async.processor.BillingRequestProcessor()
        );
        this.workerPool = new WorkerPool(poolSize, requestQueue, processors);
        Runtime.getRuntime().addShutdownHook(new Thread(this::shutdown));
    }

    public static synchronized AsyncProcessorManager getInstance() {
        if (instance == null) {
            instance = new AsyncProcessorManager();
        }
        return instance;
    }

    public CompletableFuture<AsyncResponse> submitRequest(String requestType, java.util.Map<String, Object> parameters) {
        String requestId = UUID.randomUUID().toString();
        AsyncRequest request = new AsyncRequest(requestId, requestType, parameters);

        if (workerPool.submitRequest(request)) {
            return request.getFuture();
        } else {
            CompletableFuture<AsyncResponse> failedFuture = new CompletableFuture<>();
            failedFuture.completeExceptionally(new RuntimeException("Request queue is full"));
            return failedFuture;
        }
    }

    public CompletableFuture<AsyncResponse> submitRequest(String requestType,
                                                         java.util.Map<String, Object> parameters,
                                                         long timeout) {
        String requestId = UUID.randomUUID().toString();
        AsyncRequest request = new AsyncRequest(requestId, requestType, parameters);

        try {
            if (workerPool.submitRequest(request, timeout)) {
                return request.getFuture().orTimeout(timeout, TimeUnit.MILLISECONDS);
            } else {
                CompletableFuture<AsyncResponse> failedFuture = new CompletableFuture<>();
                failedFuture.completeExceptionally(new RuntimeException("Request queue is full or timeout"));
                return failedFuture;
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            CompletableFuture<AsyncResponse> failedFuture = new CompletableFuture<>();
            failedFuture.completeExceptionally(e);
            return failedFuture;
        }
    }

    public QueueStats getQueueStats() {
        return new QueueStats(
            requestQueue.size(),
            requestQueue.remainingCapacity(),
            workerPool.getActiveCount(),
            workerPool.isRunning()
        );
    }

    public void shutdown() {
        System.out.println("Shutting down AsyncProcessorManager...");
        workerPool.shutdown();
        System.out.println("AsyncProcessorManager shutdown complete");
    }

    public static class QueueStats {
        public final int queueSize;
        public final int remainingCapacity;
        public final int activeWorkers;
        public final boolean isRunning;

        public QueueStats(int queueSize, int remainingCapacity, int activeWorkers, boolean isRunning) {
            this.queueSize = queueSize;
            this.remainingCapacity = remainingCapacity;
            this.activeWorkers = activeWorkers;
            this.isRunning = isRunning;
        }

        @Override
        public String toString() {
            return String.format("QueueStats{queueSize=%d, remainingCapacity=%d, activeWorkers=%d, isRunning=%s}",
                               queueSize, remainingCapacity, activeWorkers, isRunning);
        }
    }
}