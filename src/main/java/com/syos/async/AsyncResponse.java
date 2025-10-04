package com.syos.async;

public class AsyncResponse {
    private final String requestId;
    private final boolean success;
    private final Object data;
    private final String errorMessage;
    private final long processingTime;

    private AsyncResponse(Builder builder) {
        this.requestId = builder.requestId;
        this.success = builder.success;
        this.data = builder.data;
        this.errorMessage = builder.errorMessage;
        this.processingTime = builder.processingTime;
    }

    public String getRequestId() {
        return requestId;
    }

    public boolean isSuccess() {
        return success;
    }

    public Object getData() {
        return data;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public long getProcessingTime() {
        return processingTime;
    }

    public static Builder success(String requestId, Object data) {
        return new Builder(requestId, true).data(data);
    }

    public static Builder error(String requestId, String errorMessage) {
        return new Builder(requestId, false).errorMessage(errorMessage);
    }

    public static class Builder {
        private final String requestId;
        private final boolean success;
        private Object data;
        private String errorMessage;
        private long processingTime;

        private Builder(String requestId, boolean success) {
            this.requestId = requestId;
            this.success = success;
            this.processingTime = System.currentTimeMillis();
        }

        public Builder data(Object data) {
            this.data = data;
            return this;
        }

        public Builder errorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
            return this;
        }

        public Builder processingTime(long processingTime) {
            this.processingTime = processingTime;
            return this;
        }

        public AsyncResponse build() {
            return new AsyncResponse(this);
        }
    }
}