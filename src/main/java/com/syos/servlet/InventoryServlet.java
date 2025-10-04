package com.syos.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.command.AddProductCommand;
import com.syos.command.AssignDiscountCommand;
import com.syos.command.Command;
import com.syos.command.CreateDiscountCommand;
import com.syos.command.MoveToShelfCommand;
import com.syos.command.ReceiveStockCommand;
import com.syos.command.RemoveCloseToExpiryStockCommand;
import com.syos.command.ViewStockCommand;
import com.syos.command.ViewExpiryStockCommand;
import com.syos.command.UnassignDiscountCommand;
import com.syos.command.UpdateProductCommand;
import com.syos.command.ViewAllInventoryStocksCommand;
import com.syos.command.ViewExpiringBatchesCommand;
import com.syos.command.DiscardExpiringBatchesCommand;
import com.syos.command.ViewAllProductsCommand;
import com.syos.command.ViewAllProductsWithDiscountsCommand;
import com.syos.command.ViewAllDiscountsCommand;

import com.syos.repository.DiscountRepository;
import com.syos.repository.ProductRepository;

import com.syos.singleton.InventoryManager;

import com.syos.strategy.ExpiryAwareFifoStrategy;
import com.syos.util.CommonVariables;

import com.syos.service.ProductService;
import com.syos.service.StockAlertService;
import com.syos.service.DiscountCreationService;
import com.syos.service.StockService;
import com.syos.service.DiscountService;

import com.syos.model.StockBatch;
import com.syos.model.Discount;
import com.syos.model.Product;
import com.syos.enums.DiscountType;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private final InventoryManager inventoryManager;
    private final Map<String, Command> commandMap = new HashMap<>();
    private final Scanner scanner = new Scanner(System.in); 

    public InventoryServlet() {
        ProductRepository productRepository = new ProductRepository();
        DiscountRepository discountRepository = new DiscountRepository();

        this.inventoryManager = InventoryManager.getInstance(new ExpiryAwareFifoStrategy());

        inventoryManager.addObserver(new StockAlertService(CommonVariables.STOCK_ALERT_THRESHOLD));

        ProductService productService = new ProductService();

        commandMap.put("1", new AddProductCommand(productService, scanner, productRepository));
        commandMap.put("2", new ViewAllProductsCommand(productRepository, scanner));
        commandMap.put("3", new UpdateProductCommand(productService, scanner));
        commandMap.put("4", new ReceiveStockCommand(inventoryManager, scanner));
        commandMap.put("5", new MoveToShelfCommand(inventoryManager, scanner));
        commandMap.put("6", new ViewStockCommand(inventoryManager, scanner));
        commandMap.put("7", new ViewAllInventoryStocksCommand(inventoryManager, scanner));
        commandMap.put("8", new ViewExpiryStockCommand(inventoryManager, scanner));
        commandMap.put("9", new RemoveCloseToExpiryStockCommand(inventoryManager, scanner));
        commandMap.put("10", new ViewExpiringBatchesCommand(inventoryManager, scanner));
        commandMap.put("11", new DiscardExpiringBatchesCommand(inventoryManager, scanner));
        commandMap.put("12", new CreateDiscountCommand(scanner, discountRepository));
        commandMap.put("13", new AssignDiscountCommand(scanner, discountRepository, productRepository));
        commandMap.put("14", new ViewAllDiscountsCommand(discountRepository, scanner));
        commandMap.put("15", new ViewAllProductsWithDiscountsCommand(discountRepository, productRepository));
        commandMap.put("16", new UnassignDiscountCommand(scanner, discountRepository, productRepository));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/inventory.jsp").forward(request, response);
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
        try {
            ProductService productService = new ProductService();
            productService.updateProductName(code, newName);
            request.setAttribute("message", "Product updated successfully.");
        } catch (Exception e) {
            request.setAttribute("error", "Error updating product: " + e.getMessage());
        }
        doGet(request, response);
    }

    private void handleReceiveStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");
        String purchaseDateStr = request.getParameter("purchaseDate");
        String expiryDateStr = request.getParameter("expiryDate");
        try {
            int quantity = Integer.parseInt(quantityStr);
            LocalDate purchaseDate = LocalDate.parse(purchaseDateStr);
            LocalDate expiryDate = LocalDate.parse(expiryDateStr);
            StockService stockService = new StockService();
            stockService.receiveStock(productCode, purchaseDate, expiryDate, quantity);
            request.setAttribute("message", "Stock received successfully.");
        } catch (Exception e) {
            request.setAttribute("error", "Error receiving stock: " + e.getMessage());
        }
        doGet(request, response);
    }

    private void handleMoveToShelf(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String quantityStr = request.getParameter("quantity");
        try {
            int quantity = Integer.parseInt(quantityStr);
            StockService stockService = new StockService();
            stockService.moveToShelf(code, quantity);
            request.setAttribute("message", "Stock moved to shelf successfully.");
        } catch (Exception e) {
            request.setAttribute("error", "Error moving to shelf: " + e.getMessage());
        }
        doGet(request, response);
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
        request.setAttribute("inventoryManager", stockService); // Note: keeping for compatibility, but ideally use service methods
        request.getRequestDispatcher("/viewStock.jsp").forward(request, response);
    }

    private void handleViewAllInventoryStocks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StockService stockService = new StockService();
        List<String> productCodes = stockService.getAllProductCodes();
        request.setAttribute("productCodes", productCodes);
        request.setAttribute("inventoryManager", stockService); // compatibility
        request.getRequestDispatcher("/viewAllInventoryStocks.jsp").forward(request, response);
    }

    private void handleViewExpiryStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StockService stockService = new StockService();
        List<String> productCodes = stockService.getAllProductCodes();
        request.setAttribute("productCodes", productCodes);
        request.setAttribute("inventoryManager", stockService);
        request.getRequestDispatcher("/viewExpiryStock.jsp").forward(request, response);
    }

    private void handleRemoveCloseToExpiryStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String daysStr = request.getParameter("days");
        String productCode = request.getParameter("productCode");
        String quantityStr = request.getParameter("quantity");
        if (daysStr != null) {
            // First step: show list
            int days = Integer.parseInt(daysStr);
            List<String> products = inventoryManager.getAllProductCodesWithExpiringBatches(days);
            request.setAttribute("expiringProducts", products);
            request.setAttribute("days", days);
            request.setAttribute("inventoryManager", inventoryManager);
            request.getRequestDispatcher("/removeExpiryStock.jsp").forward(request, response);
        } else if (productCode != null && quantityStr != null) {
            // Second step: remove
            int quantity = Integer.parseInt(quantityStr);
            try {
                inventoryManager.removeQuantityFromShelf(productCode, quantity);
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
            // First step: show list
            int days = Integer.parseInt(daysStr);
            List<StockBatch> batches = inventoryManager.getAllExpiringBatches(days);
            request.setAttribute("batches", batches);
            request.setAttribute("days", days);
            request.getRequestDispatcher("/discardExpiringBatches.jsp").forward(request, response);
        } else if (batchIdStr != null && quantityStr != null && daysStr != null) {
            // Second step: discard
            int batchId = Integer.parseInt(batchIdStr);
            int quantity = Integer.parseInt(quantityStr);
            int days = Integer.parseInt(daysStr);
            List<StockBatch> expiringBatches = inventoryManager.getAllExpiringBatches(days);
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
                StockService stockService = new StockService();
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
            DiscountRepository discountRepository = new DiscountRepository();
            int id = discountRepository.createDiscount(name, type, value, startDate, endDate);
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
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountRepository discountRepository = new DiscountRepository();
            discountRepository.linkProductToDiscount(productCode, discountId);
            request.setAttribute("message", "Discount assigned successfully.");
        } catch (Exception e) {
            request.setAttribute("error", "Error assigning discount: " + e.getMessage());
        }
        doGet(request, response);
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
        request.setAttribute("discountRepository", new DiscountRepository()); // for compatibility
        request.setAttribute("today", LocalDate.now());
        request.getRequestDispatcher("/viewAllProductsWithDiscounts.jsp").forward(request, response);
    }

    private void handleUnassignDiscount(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String productCode = request.getParameter("productCode");
        String discountIdStr = request.getParameter("discountId");
        try {
            int discountId = Integer.parseInt(discountIdStr);
            DiscountRepository discountRepository = new DiscountRepository();
            boolean success = discountRepository.unassignDiscountFromProduct(productCode, discountId);
            if (success) {
                request.setAttribute("message", "Discount unassigned successfully.");
            } else {
                request.setAttribute("error", "Failed to unassign discount.");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error unassigning discount: " + e.getMessage());
        }
        doGet(request, response);
    }
}