package com.syos.servlet;

import java.io.IOException;
import java.util.HashMap;
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

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private final InventoryManager inventoryManager;
    private final Map<String, Command> commandMap = new HashMap<>();
    private final Scanner scanner = new Scanner(System.in); // Note: for commands that use scanner, may need adjustment

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
            // Add other cases as needed
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
        String category = request.getParameter("category");

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
        ProductRepository productRepository = new ProductRepository();
        var products = productRepository.findAll();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/viewProducts.jsp").forward(request, response);
    }
}