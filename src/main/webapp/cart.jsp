<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.ProductService" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%
    ProductService productService = new ProductService();

    // Get cart from session
    @SuppressWarnings("unchecked")
    Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<String, Integer>();
    }

    double total = 0;
    for (Map.Entry<String, Integer> entry : cart.entrySet()) {
        Product product = productService.findProductByCode(entry.getKey());
        if (product != null) {
            total += product.getPrice() * entry.getValue();
        }
    }

    request.setAttribute("cart", cart);
    request.setAttribute("total", total);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Shopping Cart - SYOS System</title>
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
                <a href="customerProducts.jsp" class="btn btn-outline-light btn-sm me-2">
                    <i class="bi bi-shop"></i> Shop
                </a>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2 class="mb-4">Shopping Cart</h2>

                <% if (cart.isEmpty()) { %>
                    <div class="alert alert-info">Your cart is empty. <a href="customerProducts.jsp">Start shopping</a></div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th>Total</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map.Entry<String, Integer> entry : cart.entrySet()) {
                                    Product product = productService.findProductByCode(entry.getKey());
                                    if (product != null) {
                                        double itemTotal = product.getPrice() * entry.getValue();
                                %>
                                    <tr>
                                        <td><%= product.getName() %> (<%= product.getCode() %>)</td>
                                        <td><%= entry.getValue() %></td>
                                        <td>Rs. <%= product.getPrice() %></td>
                                        <td>Rs. <%= itemTotal %></td>
                                        <td>
                                            <form action="updateCart" method="post" class="d-inline">
                                                <input type="hidden" name="productCode" value="<%= product.getCode() %>">
                                                <input type="hidden" name="action" value="remove">
                                                <button type="submit" class="btn btn-sm btn-danger">Remove</button>
                                            </form>
                                        </td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <h4>Total: Rs. <%= total %></h4>
                        <a href="checkout" class="btn btn-success btn-lg">Proceed to Checkout</a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>