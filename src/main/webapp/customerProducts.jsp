<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.ProductService" %>
<%@ page import="com.syos.service.StockService" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    ProductService productService = new ProductService();
    StockService stockService = new StockService();
    List<String> productCodesWithOnlineStock = stockService.getProductCodesWithOnlineStock();
    List<Product> products = new ArrayList<Product>();
    for (String code : productCodesWithOnlineStock) {
        Product product = productService.findProductByCode(code);
        if (product != null) {
            products.add(product);
        }
    }

    @SuppressWarnings("unchecked")
    Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<String, Integer>();
        session.setAttribute("cart", cart);
    }

    request.setAttribute("products", products);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Products - SYOS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <span class="navbar-brand">SYOS Customer Portal</span>
            <div class="d-flex">
                <span class="navbar-text me-3">
                    Welcome, <%= session.getAttribute("userName") %> (Customer)
                </span>
                <a href="cart.jsp" class="btn btn-outline-light btn-sm me-2">
                    <i class="bi bi-cart"></i> Cart (<%= cart.size() %>)
                </a>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2 class="mb-4">Available Products</h2>

                <div class="row">
                    <% for (Product product : products) { %>
                        <div class="col-md-4 mb-4">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title"><%= product.getName() %></h5>
                                    <p class="card-text">Code: <%= product.getCode() %></p>
                                    <p class="card-text fw-bold">Rs. <%= product.getPrice() %></p>
                                    <form action="addToCart" method="post" class="d-inline">
                                        <input type="hidden" name="productCode" value="<%= product.getCode() %>">
                                        <button type="submit" class="btn btn-primary">Add to Cart</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</body>
</html>