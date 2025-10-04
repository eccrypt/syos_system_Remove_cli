package com.syos.async;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

public class RequestQueue {
    private final BlockingQueue<AsyncRequest> queue;
    private final int capacity;

    public RequestQueue(int capacity) {
        this.capacity = capacity;
        this.queue = new LinkedBlockingQueue<>(capacity);
    }

    public boolean offer(AsyncRequest request) {
        return queue.offer(request);
    }

    public boolean offer(AsyncRequest request, long timeout) throws InterruptedException {
        return queue.offer(request, timeout, TimeUnit.MILLISECONDS);
    }

    public AsyncRequest poll() {
        return queue.poll();
    }

    public AsyncRequest poll(long timeout) throws InterruptedException {
        return queue.poll(timeout, TimeUnit.MILLISECONDS);
    }

    public int size() {
        return queue.size();
    }

    public boolean isEmpty() {
        return queue.isEmpty();
    }

    public boolean isFull() {
        return queue.size() >= capacity;
    }

    public int remainingCapacity() {
        return queue.remainingCapacity();
    }

    public void clear() {
        queue.clear();
    }
}