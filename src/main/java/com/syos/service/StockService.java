package com.syos.service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import com.syos.model.StockBatch;
import com.syos.singleton.InventoryManager;
import com.syos.websocket.RealtimeBroadcastService;

public class StockService {
    private final InventoryManager inventoryManager;
    private final RealtimeBroadcastService broadcastService;

    public StockService() {
        this.inventoryManager = InventoryManager.getInstance(null);
        this.broadcastService = RealtimeBroadcastService.getInstance();
    }

    public void receiveStock(String productCode, LocalDate purchaseDate, LocalDate expiryDate, int quantity) {
        inventoryManager.receiveStock(productCode, purchaseDate, expiryDate, quantity);
        // Broadcast stock update
        int shelfQty = getQuantityOnShelf(productCode);
        int onlineQty = getQuantityOnline(productCode);
        broadcastService.broadcastStockUpdate(productCode, shelfQty, onlineQty);
    }

    public void moveToShelf(String productCode, int quantity) {
        inventoryManager.moveToShelf(productCode, quantity);
        // Broadcast stock update
        int shelfQty = getQuantityOnShelf(productCode);
        int onlineQty = getQuantityOnline(productCode);
        broadcastService.broadcastStockUpdate(productCode, shelfQty, onlineQty);
    }

    public void moveToOnline(String productCode, int quantity) {
        inventoryManager.moveToOnline(productCode, quantity);
        // Broadcast stock update
        int shelfQty = getQuantityOnShelf(productCode);
        int onlineQty = getQuantityOnline(productCode);
        broadcastService.broadcastStockUpdate(productCode, shelfQty, onlineQty);
    }

    public int getQuantityOnShelf(String productCode) {
        return inventoryManager.getQuantityOnShelf(productCode);
    }

    public int getQuantityOnline(String productCode) {
        return inventoryManager.getQuantityOnline(productCode);
    }

    public void deductFromOnline(String productCode, int quantity) {
        inventoryManager.deductFromOnline(productCode, quantity);
        // Broadcast stock update
        int shelfQty = getQuantityOnShelf(productCode);
        int onlineQty = getQuantityOnline(productCode);
        broadcastService.broadcastStockUpdate(productCode, shelfQty, onlineQty);
    }

    public List<String> getProductCodesWithOnlineStock() {
        return inventoryManager.getOnlineRepository().getAllProductCodes().stream()
                .filter(code -> getQuantityOnline(code) > 0)
                .collect(Collectors.toList());
    }

    public List<String> getAllProductCodes() {
        return inventoryManager.getAllProductCodes();
    }

    public List<StockBatch> getBatchesForProduct(String productCode) {
        return inventoryManager.getBatchesForProduct(productCode);
    }

    public void discardBatchQuantity(int batchId, int quantity) {
        inventoryManager.discardBatchQuantity(batchId, quantity);
    }

    public void discardBatch(int batchId) {
        inventoryManager.removeEntireBatch(batchId);
    }

    public List<String> getAllProductCodesWithExpiringBatches(int days) {
        return inventoryManager.getAllProductCodesWithExpiringBatches(days);
    }

    public List<StockBatch> getAllExpiringBatches(int days) {
        return inventoryManager.getAllExpiringBatches(days);
    }

    public int getAvailableStock(String productCode) {
    	return inventoryManager.getAvailableStock(productCode);
    }
   
    public int getAvailableNonExpiredStock(String productCode) {
    	return inventoryManager.getAvailableNonExpiredStock(productCode);
    }

    public void removeQuantityFromShelf(String productCode, int quantity) {
        inventoryManager.removeQuantityFromShelf(productCode, quantity);
        // Broadcast stock update
        int shelfQty = getQuantityOnShelf(productCode);
        int onlineQty = getQuantityOnline(productCode);
        broadcastService.broadcastStockUpdate(productCode, shelfQty, onlineQty);
    }

    public List<StockBatch> getExpiringBatchesForProduct(String productCode, int days) {
        return inventoryManager.getExpiringBatchesForProduct(productCode, days);
    }
}