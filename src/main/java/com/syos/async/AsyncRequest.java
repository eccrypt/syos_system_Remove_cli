package com.syos.async;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * Represents an asynchronous request that can be queued and processed by worker threads
 */
public class AsyncRequest {
    private final String requestId;
    private final String requestType;
    private final Map<String, Object> parameters;
    private final CompletableFuture<AsyncResponse> future;
    private final long timestamp;

    public AsyncRequest(String requestId, String requestType, Map<String, Object> parameters) {
        this.requestId = requestId;
        this.requestType = requestType;
        this.parameters = parameters;
        this.future = new CompletableFuture<>();
        this.timestamp = System.currentTimeMillis();
    }

    public String getRequestId() {
        return requestId;
    }

    public String getRequestType() {
        return requestType;
    }

    public Map<String, Object> getParameters() {
        return parameters;
    }

    public CompletableFuture<AsyncResponse> getFuture() {
        return future;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public boolean isExpired(long timeoutMillis) {
        return System.currentTimeMillis() - timestamp > timeoutMillis;
    }

    public void complete(AsyncResponse response) {
        future.complete(response);
    }

    public void completeExceptionally(Throwable throwable) {
        future.completeExceptionally(throwable);
    }
}