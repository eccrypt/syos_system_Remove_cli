package com.syos.service;

import java.time.LocalDate;
import java.util.List;

import com.syos.model.StockBatch;
import com.syos.singleton.InventoryManager;

public class StockService {
    private final InventoryManager inventoryManager;

    public StockService() {
        this.inventoryManager = InventoryManager.getInstance(null);
    }

    public void receiveStock(String productCode, LocalDate purchaseDate, LocalDate expiryDate, int quantity) {
        inventoryManager.receiveStock(productCode, purchaseDate, expiryDate, quantity);
    }

    public void moveToShelf(String productCode, int quantity) {
        inventoryManager.moveToShelf(productCode, quantity);
    }

    public int getQuantityOnShelf(String productCode) {
        return inventoryManager.getQuantityOnShelf(productCode);
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

    public List<String> getAllProductCodesWithExpiringBatches(int days) {
        return inventoryManager.getAllProductCodesWithExpiringBatches(days);
    }

    public List<StockBatch> getAllExpiringBatches(int days) {
        return inventoryManager.getAllExpiringBatches(days);
    }

    public int getAvailableStock(String productCode) {
        return inventoryManager.getAvailableStock(productCode);
    }

    public void removeQuantityFromShelf(String productCode, int quantity) {
        inventoryManager.removeQuantityFromShelf(productCode, quantity);
    }

    public List<StockBatch> getExpiringBatchesForProduct(String productCode, int days) {
        return inventoryManager.getExpiringBatchesForProduct(productCode, days);
    }
}