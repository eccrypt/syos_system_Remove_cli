package com.syos.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.service.ProductService;
import com.syos.service.StockService;
import com.syos.service.DiscountService;

import com.syos.model.StockBatch;
import com.syos.model.Discount;
import com.syos.model.Product;
import com.syos.enums.DiscountType;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    public InventoryServlet() {
    
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("editProduct".equals(action)) {
            String code = request.getParameter("code");
            ProductService productService = new ProductService();
            Product product = productService.findProductByCode(code);
            request.setAttribute("editProduct", product);
            request.getRequestDispatcher("/productManagement.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/inventory.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            doGet(request, response);
            return;
        }

        switch (action) {
            case "addProduct":
                handleAddProduct(request, response);
                break;
            case "viewProducts":
                handleViewProducts(request, response);
                break;
            case "updateProduct":
                handleUpdateProduct(request, response);
                break;
            case "receiveStock":
                handleReceiveStock(request, response);
                break;
            case "moveToShelf":
                handleMoveToShelf(request, response);
                break;
            case "viewStock":
                handleViewStock(request, response);
                break;
            case "viewAllInventoryStocks":
                handleViewAllInventoryStocks(request, response);
                break;
            case "viewExpiryStock":
                handleViewExpiryStock(request, response);
                break;
            case "removeCloseToExpiryStock":
                handleRemoveCloseToExpiryStock(request, response);
                break;
            case "viewExpiringBatches":
                handleViewExpiringBatches(request, response);
                break;
            case "discardExpiringBatches":
                handleDiscardExpiringBatches(request, response);
                break;
            case "discardBatch":
                handleDiscardBatch(request, response);
                break;
            case "createDiscount":
                handleCreateDiscount(request, response);
                break;
            case "assignDiscount":
                handleAssignDiscount(request, response);
                break;
            case "viewAllDiscounts":
                handleViewAllDiscounts(request, response);
                break;
            case "viewAllProductsWithDiscounts":
                handleViewAllProductsWithDiscounts(request, response);
                break;
            case "unassignDiscount":
                handleUnassignDiscount(request, response);
                break;
            case "updateDiscount":
                handleUpdateDiscount(request, response);
                break;
            case "deleteDiscount":
                handleDeleteDiscount(request, response);
                break;
            default:
                request.setAttribute("error", "Unknown action.");
                doGet(request, response);
        }
    }

    private void handleAddProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String code = request.getParameter("code");
        String priceStr = request.getParameter("price");
        try {
            double price = Double.parseDouble(priceStr);
            ProductService productService = new ProductService();
            productService.addProduct(code, name, price);
            request.setAttribute("message", "Product added successfully.");
        } catch (Exception e) {
            request.setAttribute("error", "Error adding product: " + e.getMessage());
        }
        doGet(request, response);
    }

    private void handleViewProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductService productService = new ProductService();
        var products = productService.getAllProducts();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/viewProducts.jsp").forward(request, response);
    }

    private void handleUpdateProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String newName = request.getParameter("newName");
        String newPriceStr = request.getParameter("newPrice");
        String message = null;
        String error = null;
        try {
            double newPrice = Double.parseDouble(newPriceStr);
            ProductService productService = new ProductService();
            productService.updateProduct(code, newName, newPrice);
            message = "Product updated successfully.";
        } catch (Exception e) {
            error = "Error updating product: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/stockManagement.jsp");
    }

    private void handleReceiveStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");
        String purchaseDateStr = request.getParameter("purchaseDate");
        String expiryDateStr = request.getParameter("expiryDate");
        String message = null;
        String error = null;
        try {
            int quantity = Integer.parseInt(quantityStr);
            LocalDate purchaseDate = LocalDate.parse(purchaseDateStr);
            LocalDate expiryDate = LocalDate.parse(expiryDateStr);
            StockService stockService = new StockService();
            stockService.receiveStock(productCode, purchaseDate, expiryDate, quantity);
            message = "Stock received successfully.";
        } catch (Exception e) {
            error = "Error receiving stock: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/stockManagement.jsp");
    }

    private void handleMoveToShelf(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String quantityStr = request.getParameter("quantity");
        String message = null;
        String error = null;
        try {
            int quantity = Integer.parseInt(quantityStr);
            StockService stockService = new StockService();
            stockService.moveToShelf(code, quantity);
            message = "Stock moved to shelf successfully.";
        } catch (Exception e) {
            error = "Error moving to shelf: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/productManagement.jsp");
    }

    private void handleViewStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        StockService stockService = new StockService();
        List<String> productCodes;
        if (productCode != null && !productCode.isEmpty()) {
            productCodes = List.of(productCode);
        } else {
            productCodes = stockService.getAllProductCodes();
        }
        request.setAttribute("productCodes", productCodes);
        request.setAttribute("stockService", stockService);
        request.getRequestDispatcher("/viewStock.jsp").forward(request, response);
    }

    private void handleViewAllInventoryStocks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StockService stockService = new StockService();
        List<String> productCodes = stockService.getAllProductCodes();
        request.setAttribute("productCodes", productCodes);
        request.setAttribute("stockService", stockService);
        request.getRequestDispatcher("/viewAllInventoryStocks.jsp").forward(request, response);
    }

    private void handleViewExpiryStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StockService stockService = new StockService();
        List<String> productCodes = stockService.getAllProductCodes();
        request.setAttribute("productCodes", productCodes);
        request.setAttribute("stockService", stockService);
        request.getRequestDispatcher("/viewExpiryStock.jsp").forward(request, response);
    }

    private void handleRemoveCloseToExpiryStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String daysStr = request.getParameter("days");
        String productCode = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");
        if (daysStr != null) {
            int days = Integer.parseInt(daysStr);
            StockService stockService = new StockService();
            List<String> products = stockService.getAllProductCodesWithExpiringBatches(days);
            request.setAttribute("expiringProducts", products);
            request.setAttribute("days", days);
            request.setAttribute("stockService", stockService);
            request.getRequestDispatcher("/removeExpiryStock.jsp").forward(request, response);
        } else if (productCode != null && quantityStr != null) {
            int quantity = Integer.parseInt(quantityStr);
            try {
                StockService stockService = new StockService();
                stockService.removeQuantityFromShelf(productCode, quantity);
                request.setAttribute("message", "Stock removed from shelf successfully.");
            } catch (Exception e) {
                request.setAttribute("error", "Error removing stock: " + e.getMessage());
            }
            doGet(request, response);
        } else {
            request.setAttribute("error", "Invalid parameters for remove close to expiry stock.");
            doGet(request, response);
        }
    }

    private void handleViewExpiringBatches(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String daysStr = request.getParameter("days");
        int days = Integer.parseInt(daysStr);
        StockService stockService = new StockService();
        List<StockBatch> batches = stockService.getAllExpiringBatches(days);
        request.setAttribute("batches", batches);
        request.setAttribute("days", days);
        request.getRequestDispatcher("/viewExpiringBatches.jsp").forward(request, response);
    }

    private void handleDiscardExpiringBatches(HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
         String daysStr = request.getParameter("days");
         String batchIdStr = request.getParameter("batchId");
         String quantityStr = request.getParameter("quantity");
         if (daysStr != null && batchIdStr == null) {
             int days = Integer.parseInt(daysStr);
             StockService stockService = new StockService();
             List<StockBatch> batches = stockService.getAllExpiringBatches(days);
             request.setAttribute("batches", batches);
             request.setAttribute("days", days);
             request.getRequestDispatcher("/discardExpiringBatches.jsp").forward(request, response);
         } else if (batchIdStr != null && quantityStr != null && daysStr != null) {
             int batchId = Integer.parseInt(batchIdStr);
             int quantity = Integer.parseInt(quantityStr);
             int days = Integer.parseInt(daysStr);
             StockService stockService = new StockService();
             List<StockBatch> expiringBatches = stockService.getAllExpiringBatches(days);
             StockBatch selectedBatch = null;
             for (StockBatch batch : expiringBatches) {
                 if (batch.getId() == batchId) {
                     selectedBatch = batch;
                     break;
                 }
             }
             if (selectedBatch == null) {
                 request.setAttribute("error", "Batch not found in expiring list.");
                 doGet(request, response);
                 return;
             }
             if (quantity == 0) {
                 quantity = selectedBatch.getQuantityRemaining();
             }
             try {
                 stockService.discardBatchQuantity(batchId, quantity);
                 request.setAttribute("message", "Batch discarded successfully.");
             } catch (Exception e) {
                 request.setAttribute("error", "Error discarding batch: " + e.getMessage());
             }
             doGet(request, response);
         } else {
             request.setAttribute("error", "Invalid parameters for discard expiring batches.");
             doGet(request, response);
         }
     }

     private void handleDiscardBatch(HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
         String batchIdStr = request.getParameter("batchId");
         String message = null;
         String error = null;
         try {
             int batchId = Integer.parseInt(batchIdStr);
             StockService stockService = new StockService();
             stockService.discardBatch(batchId);
             message = "Batch discarded successfully.";
         } catch (Exception e) {
             error = "Error discarding batch: " + e.getMessage();
         }
         handleResponse(request, response, message, error, "/stockManagement.jsp");
     }

    private void handleCreateDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String typeStr = request.getParameter("type");
        String valueStr = request.getParameter("value");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        try {
            DiscountType type = DiscountType.valueOf(typeStr.toUpperCase());
            double value = Double.parseDouble(valueStr);
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);
            DiscountService discountService = new DiscountService();
            int id = discountService.createDiscount(name, type, value, startDate, endDate);
            request.setAttribute("message", "Discount created successfully with ID: " + id);
        } catch (Exception e) {
            request.setAttribute("error", "Error creating discount: " + e.getMessage());
        }
        doGet(request, response);
    }

    private void handleAssignDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        String discountIdStr = request.getParameter("discountId");
        String message = null;
        String error = null;
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountService discountService = new DiscountService();
            discountService.assignDiscountToProduct(productCode, discountId);
            message = "Discount assigned successfully.";
        } catch (Exception e) {
            error = "Error assigning discount: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/discountManagement.jsp");
    }

    private void handleViewAllDiscounts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DiscountService discountService = new DiscountService();
        List<Discount> discounts = discountService.getAllDiscounts();
        request.setAttribute("discounts", discounts);
        request.getRequestDispatcher("/viewAllDiscounts.jsp").forward(request, response);
    }

    private void handleViewAllProductsWithDiscounts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DiscountService discountService = new DiscountService();
        List<Product> products = discountService.getProductsWithActiveDiscounts(LocalDate.now());
        request.setAttribute("products", products);
        request.setAttribute("discountService", discountService);
        request.setAttribute("today", LocalDate.now());
        request.getRequestDispatcher("/viewAllProductsWithDiscounts.jsp").forward(request, response);
    }

    private void handleUnassignDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        String discountIdStr = request.getParameter("discountId");
        String message = null;
        String error = null;
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountService discountService = new DiscountService();
            boolean success = discountService.unassignDiscountFromProduct(productCode, discountId);
            if (success) {
                message = "Discount unassigned successfully.";
            } else {
                error = "Failed to unassign discount.";
            }
        } catch (Exception e) {
            error = "Error unassigning discount: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/discountManagement.jsp");
    }

    private void handleUpdateDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String discountIdStr = request.getParameter("discountId");
        String name = request.getParameter("name");
        String typeStr = request.getParameter("type");
        String valueStr = request.getParameter("value");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String message = null;
        String error = null;
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountType type = DiscountType.valueOf(typeStr.toUpperCase());
            double value = Double.parseDouble(valueStr);
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);
            DiscountService discountService = new DiscountService();
            discountService.updateDiscount(discountId, name, type, value, startDate, endDate);
            message = "Discount updated successfully.";
        } catch (Exception e) {
            error = "Error updating discount: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/discountManagement.jsp");
    }

    private void handleDeleteDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String discountIdStr = request.getParameter("discountId");
        String message = null;
        String error = null;
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountService discountService = new DiscountService();
            discountService.deleteDiscount(discountId);
            message = "Discount deleted successfully.";
        } catch (Exception e) {
            error = "Error deleting discount: " + e.getMessage();
        }
        handleResponse(request, response, message, error, "/discountManagement.jsp");
    }

    private void handleResponse(HttpServletRequest request, HttpServletResponse response, String message, String error, String page)
            throws ServletException, IOException {
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
        if (isAjax) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String json;
            if (error != null) {
                json = "{\"error\": \"" + error.replace("\"", "\\\"") + "\"}";
            } else {
                json = "{\"success\": true, \"message\": \"" + message.replace("\"", "\\\"") + "\"}";
            }
            response.getWriter().write(json);
        } else {
            if (error != null) {
                request.setAttribute("error", error);
            } else {
                request.setAttribute("message", message);
            }
            request.getRequestDispatcher(page).forward(request, response);
        }
    }
}