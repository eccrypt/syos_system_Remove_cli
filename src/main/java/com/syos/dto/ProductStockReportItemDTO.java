package com.syos.dto;

import java.time.LocalDate;

public class ProductStockReportItemDTO {
	private String productCode;
	private String productName;
	private double unitPrice;
	private int totalQuantityOnShelf;
	private int totalQuantityInInventory; 
	private LocalDate earliestExpiryDateOnShelf; 
	private LocalDate earliestExpiryDateInInventory; 
	private int numberOfExpiringBatches; 

	public ProductStockReportItemDTO(String productCode, String productName, double unitPrice, int totalQuantityOnShelf,
			int totalQuantityInInventory, LocalDate earliestExpiryDateOnShelf, LocalDate earliestExpiryDateInInventory,
			int numberOfExpiringBatches) {
		this.productCode = productCode;
		this.productName = productName;
		this.unitPrice = unitPrice;
		this.totalQuantityOnShelf = totalQuantityOnShelf;
		this.totalQuantityInInventory = totalQuantityInInventory;
		this.earliestExpiryDateOnShelf = earliestExpiryDateOnShelf;
		this.earliestExpiryDateInInventory = earliestExpiryDateInInventory;
		this.numberOfExpiringBatches = numberOfExpiringBatches;
	}

	public String getProductCode() {
		return productCode;
	}

	public String getProductName() {
		return productName;
	}

	public double getUnitPrice() {
		return unitPrice;
	}

	public int getTotalQuantityOnShelf() {
		return totalQuantityOnShelf;
	}

	public int getTotalQuantityInInventory() {
		return totalQuantityInInventory;
	}

	public LocalDate getEarliestExpiryDateOnShelf() {
		return earliestExpiryDateOnShelf;
	}

	public LocalDate getEarliestExpiryDateInInventory() {
		return earliestExpiryDateInInventory;
	}

	public int getNumberOfExpiringBatches() {
		return numberOfExpiringBatches;
	}

	// You might want to add setters if you build this DTO incrementally,
	// but for reports, an immutable DTO via constructor is often sufficient.
}