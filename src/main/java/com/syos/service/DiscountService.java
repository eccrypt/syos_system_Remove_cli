package com.syos.service;

import java.time.LocalDate;
import java.util.List;

import com.syos.enums.DiscountType;
import com.syos.model.Discount;
import com.syos.model.Product;
import com.syos.repository.DiscountRepository;
import com.syos.repository.ProductRepository;

public class DiscountService {
    private final DiscountRepository discountRepository;
    private final ProductRepository productRepository;

    public DiscountService() {
        this.discountRepository = new DiscountRepository();
        this.productRepository = new ProductRepository();
    }

    public int createDiscount(String name, DiscountType type, double value, LocalDate startDate, LocalDate endDate) {
        return discountRepository.createDiscount(name, type, value, startDate, endDate);
    }

    public void assignDiscountToProduct(String productCode, int discountId) {
        discountRepository.linkProductToDiscount(productCode, discountId);
    }

    public boolean unassignDiscountFromProduct(String productCode, int discountId) {
        return discountRepository.unassignDiscountFromProduct(productCode, discountId);
    }

    public List<Discount> getAllDiscounts() {
        return discountRepository.findAll();
    }

    public List<Discount> getDiscountsByProductCode(String productCode, LocalDate date) {
        return discountRepository.findDiscountsByProductCode(productCode, date);
    }

    public List<Product> getProductsWithActiveDiscounts(LocalDate date) {
        return productRepository.findProductsWithActiveDiscounts(date);
    }
}