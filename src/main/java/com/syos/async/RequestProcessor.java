package com.syos.async;

public interface RequestProcessor {

    String getRequestType();

    AsyncResponse process(AsyncRequest request);

    default boolean canHandle(String requestType) {
        return getRequestType().equals(requestType);
    }
}