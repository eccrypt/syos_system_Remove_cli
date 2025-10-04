<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.ProductService" %>
<%@ page import="com.syos.service.StockService" %>
<%@ page import="com.syos.service.WebStoreBillingService" %>
<%@ page import="com.syos.singleton.InventoryManager" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    ProductService productService = new ProductService();
    StockService stockService = new StockService();
    WebStoreBillingService billingService = new WebStoreBillingService();
    InventoryManager inventoryManager = InventoryManager.getInstance(null);

    int totalProducts = productService.getAllProducts().size();
    List<String> allProductCodes = stockService.getAllProductCodes();
    int totalStockItems = allProductCodes.size();

    // Calculate total inventory value (simplified)
    double totalInventoryValue = 0;
    for (String code : allProductCodes) {
        int shelfQty = stockService.getQuantityOnShelf(code);
        Product product = productService.findProductByCode(code);
        if (product != null) {
            totalInventoryValue += shelfQty * product.getPrice();
        }
    }

    // Get today's sales from billing service
    double todaySales = billingService.getTodaySalesTotal();

    request.setAttribute("totalProducts", totalProducts);
    request.setAttribute("totalStockItems", totalStockItems);
    request.setAttribute("totalInventoryValue", totalInventoryValue);
    request.setAttribute("todaySales", todaySales);
%>
<!DOCTYPE html>
<html>
<head>
    <title>SYOS Billing System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-white">
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>
    <div class="d-flex">
        <div style="margin-left: 250px; width: calc(100% - 250px);">

            <div class="container mt-4">
                <div class="row">
                    <div class="col-12">
                        <h2 class="mb-4">Dashboard</h2>

                        <!-- Summary Cards -->
                        <div class="row mb-4">
                            <div class="col-md-3 mb-3">
                                <div class="card bg-primary text-white">
                                    <div class="card-body text-center">
                                        <i class="bi bi-tag fs-1 mb-2"></i>
                                        <h5 class="fw-bold">${totalProducts}</h5>
                                        <p class="mb-0 small">Total Products</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="card bg-success text-white">
                                    <div class="card-body text-center">
                                        <i class="bi bi-boxes fs-1 mb-2"></i>
                                        <h5 class="fw-bold">${totalStockItems}</h5>
                                        <p class="mb-0 small">Stock Items</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="card bg-info text-white">
                                    <div class="card-body text-center">
                                        <i class="bi bi-cash-coin fs-1 mb-2"></i>
                                        <h5 class="fw-bold">Rs. ${totalInventoryValue}</h5>
                                        <p class="mb-0 small">Inventory Value</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="card bg-warning text-white">
                                    <div class="card-body text-center">
                                        <i class="bi bi-graph-up fs-1 mb-2"></i>
                                        <h5 class="fw-bold">Rs. ${todaySales}</h5>
                                        <p class="mb-0 small">Today's Sales</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chart Section -->
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <div class="card">
                                    <div class="card-header">
                                        <h5>Inventory Overview</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="inventoryChart" width="150" height="75"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-header">
                                        <h5>Quick Actions</h5>
                                    </div>
                                    <div class="card-body">
                                        <%
                                            String userRole = (String) session.getAttribute("userRole");
                                            boolean isAdmin = "ADMIN".equals(userRole);
                                            boolean isStaff = "STAFF".equals(userRole);
                                        %>

                                        <% if (isAdmin || isStaff) { %>
                                        <a href="billing" class="btn btn-primary w-100 mb-2">
                                            <i class="bi bi-receipt"></i> Start Billing
                                        </a>
                                        <a href="inventory" class="btn btn-success w-100 mb-2">
                                            <i class="bi bi-box-seam"></i> Manage Inventory
                                        </a>
                                        <% } %>

                                        <% if (isAdmin) { %>
                                        <a href="reports.jsp" class="btn btn-info w-100 mb-2">
                                            <i class="bi bi-graph-up"></i> View Reports
                                        </a>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <% if (!isAdmin && !isStaff) { %>
                        <div class="alert alert-dark text-center mt-4" role="alert">
                            You don't have access to any modules. Please contact your administrator.
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <script>
                // Sample data for the chart
                const ctx = document.getElementById('inventoryChart').getContext('2d');
                const inventoryChart = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Products', 'Stock Items', 'Low Stock', 'Expiring Soon'],
                        datasets: [{
                            label: 'Inventory Summary',
                            data: [parseInt('${totalProducts}'), parseInt('${totalStockItems}'), 5, 3],
                            backgroundColor: [
                                'rgba(255, 99, 132, 0.8)',
                                'rgba(54, 162, 235, 0.8)',
                                'rgba(255, 205, 86, 0.8)',
                                'rgba(75, 192, 192, 0.8)'
                            ],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                position: 'bottom',
                            }
                        }
                    }
                });
            </script>
        </div>
    </div>
</body>
</html>