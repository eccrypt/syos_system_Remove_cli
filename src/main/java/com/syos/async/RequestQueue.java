package com.syos.async;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * Thread-safe queue for managing asynchronous requests
 */
public class RequestQueue {
    private final BlockingQueue<AsyncRequest> queue;
    private final int capacity;

    public RequestQueue(int capacity) {
        this.capacity = capacity;
        this.queue = new LinkedBlockingQueue<>(capacity);
    }

    /**
     * Add a request to the queue
     * @param request The request to add
     * @return true if added successfully, false if queue is full
     */
    public boolean offer(AsyncRequest request) {
        return queue.offer(request);
    }

    /**
     * Add a request to the queue, waiting if necessary
     * @param request The request to add
     * @param timeout Timeout in milliseconds
     * @return true if added successfully, false if timeout
     */
    public boolean offer(AsyncRequest request, long timeout) throws InterruptedException {
        return queue.offer(request, timeout, TimeUnit.MILLISECONDS);
    }

    /**
     * Retrieve and remove the head of the queue
     * @return The next request, or null if queue is empty
     */
    public AsyncRequest poll() {
        return queue.poll();
    }

    /**
     * Retrieve and remove the head of the queue, waiting if necessary
     * @param timeout Timeout in milliseconds
     * @return The next request, or null if timeout
     */
    public AsyncRequest poll(long timeout) throws InterruptedException {
        return queue.poll(timeout, TimeUnit.MILLISECONDS);
    }

    /**
     * Get the current size of the queue
     */
    public int size() {
        return queue.size();
    }

    /**
     * Check if the queue is empty
     */
    public boolean isEmpty() {
        return queue.isEmpty();
    }

    /**
     * Check if the queue is full
     */
    public boolean isFull() {
        return queue.size() >= capacity;
    }

    /**
     * Get the remaining capacity
     */
    public int remainingCapacity() {
        return queue.remainingCapacity();
    }

    /**
     * Clear all requests from the queue
     */
    public void clear() {
        queue.clear();
    }
}