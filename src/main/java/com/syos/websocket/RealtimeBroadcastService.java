package com.syos.websocket;

import java.io.IOException;
import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.Session;

import com.fasterxml.jackson.databind.ObjectMapper;

public class RealtimeBroadcastService {
    private static RealtimeBroadcastService instance;
    private final Set<Session> sessions = Collections.newSetFromMap(new ConcurrentHashMap<>());
    private final ObjectMapper objectMapper = new ObjectMapper();

    private RealtimeBroadcastService() {}

    public static synchronized RealtimeBroadcastService getInstance() {
        if (instance == null) {
            instance = new RealtimeBroadcastService();
        }
        return instance;
    }

    public void addSession(Session session) {
        sessions.add(session);
        System.out.println("WebSocket session added. Total sessions: " + sessions.size());
    }

    public void removeSession(Session session) {
        sessions.remove(session);
        System.out.println("WebSocket session removed. Total sessions: " + sessions.size());
    }

    public void broadcastUpdate(String eventType, Object data) {
        RealtimeUpdate update = new RealtimeUpdate(eventType, data, System.currentTimeMillis());

        String jsonMessage;
        try {
            jsonMessage = objectMapper.writeValueAsString(update);
        } catch (Exception e) {
            System.err.println("Error serializing update: " + e.getMessage());
            return;
        }

        // Send to all connected sessions
        for (Session session : sessions) {
            if (session.isOpen()) {
                try {
                    session.getBasicRemote().sendText(jsonMessage);
                } catch (IOException e) {
                    System.err.println("Error sending to session: " + e.getMessage());
                    // Remove broken session
                    sessions.remove(session);
                }
            } else {
                // Remove closed session
                sessions.remove(session);
            }
        }

        System.out.println("Broadcasted " + eventType + " update to " + sessions.size() + " clients");
    }

    public void broadcastInventoryUpdate(String productCode, int newQuantity) {
        InventoryUpdate data = new InventoryUpdate(productCode, newQuantity);
        broadcastUpdate("INVENTORY_UPDATE", data);
    }

    public void broadcastStockUpdate(String productCode, int shelfQuantity, int onlineQuantity) {
        StockUpdate data = new StockUpdate(productCode, shelfQuantity, onlineQuantity);
        broadcastUpdate("STOCK_UPDATE", data);
    }

    public void broadcastOrderProcessed(String productCode, int quantitySold) {
        OrderUpdate data = new OrderUpdate(productCode, quantitySold);
        broadcastUpdate("ORDER_PROCESSED", data);
    }

    public void broadcastProductAdded(String productCode, String productName, double price) {
        ProductUpdate data = new ProductUpdate(productCode, productName, price);
        broadcastUpdate("PRODUCT_ADDED", data);
    }

    public void broadcastProductUpdated(String productCode, String productName, double price) {
        ProductUpdate data = new ProductUpdate(productCode, productName, price);
        broadcastUpdate("PRODUCT_UPDATED", data);
    }

    // Data classes for different update types
    public static class RealtimeUpdate {
        public String eventType;
        public Object data;
        public long timestamp;

        public RealtimeUpdate(String eventType, Object data, long timestamp) {
            this.eventType = eventType;
            this.data = data;
            this.timestamp = timestamp;
        }
    }

    public static class InventoryUpdate {
        public String productCode;
        public int newQuantity;

        public InventoryUpdate(String productCode, int newQuantity) {
            this.productCode = productCode;
            this.newQuantity = newQuantity;
        }
    }

    public static class StockUpdate {
        public String productCode;
        public int shelfQuantity;
        public int onlineQuantity;

        public StockUpdate(String productCode, int shelfQuantity, int onlineQuantity) {
            this.productCode = productCode;
            this.shelfQuantity = shelfQuantity;
            this.onlineQuantity = onlineQuantity;
        }
    }

    public static class OrderUpdate {
        public String productCode;
        public int quantitySold;

        public OrderUpdate(String productCode, int quantitySold) {
            this.productCode = productCode;
            this.quantitySold = quantitySold;
        }
    }

    public static class ProductUpdate {
        public String productCode;
        public String productName;
        public double price;

        public ProductUpdate(String productCode, String productName, double price) {
            this.productCode = productCode;
            this.productName = productName;
            this.price = price;
        }
    }
}