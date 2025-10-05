<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.model.BillItem" %>
<%@ page import="java.util.List" %>
<%
    @SuppressWarnings("unchecked")
    List<BillItem> billItems = (List<BillItem>) request.getAttribute("billItems");
    Double total = (Double) request.getAttribute("total");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout - SYOS System</title>
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
                    <i class="bi bi-arrow-left"></i> Back to Cart
                </a>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h2>Checkout</h2>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                        <% } %>

                        <h4>Order Summary</h4>
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (BillItem item : billItems) { %>
                                    <tr>
                                        <td><%= item.getProduct().getName() %> (<%= item.getProduct().getCode() %>)</td>
                                        <td><%= item.getQuantity() %></td>
                                        <td>Rs. <%= item.getProduct().getPrice() %></td>
                                        <td>Rs. <%= item.getTotalPrice() %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>

                        <div class="d-flex justify-content-between">
                            <h4>Total: Rs. <%= total %></h4>
                        </div>

                        <form action="checkout" method="post" class="mt-4">
                            <button type="submit" class="btn btn-success btn-lg w-100">Confirm Payment</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>