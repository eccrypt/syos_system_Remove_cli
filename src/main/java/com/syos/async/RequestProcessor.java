package com.syos.async;

/**
 * Interface for processing different types of asynchronous requests
 */
public interface RequestProcessor {

    /**
     * Get the request type this processor handles
     */
    String getRequestType();

    /**
     * Process an asynchronous request
     * @param request The request to process
     * @return The response
     */
    AsyncResponse process(AsyncRequest request);

    /**
     * Check if this processor can handle the given request type
     */
    default boolean canHandle(String requestType) {
        return getRequestType().equals(requestType);
    }
}