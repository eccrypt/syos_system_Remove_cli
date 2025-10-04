<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">Inventory Management Dashboard</h1>
        <a href="index.jsp" class="btn btn-light mb-4">Back to Main Menu</a>

        <c:if test="${not empty error}">
            <div class="alert alert-dark">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-dark">${message}</div>
        </c:if>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card h-100 shadow-sm">
                    <div class="card-body text-center">
                        <h5 class="card-title">Product Management</h5>
                        <p class="card-text">Manage products: add, view, edit, and delete products.</p>
                        <a href="productManagement.jsp" class="btn btn-dark">Manage Products</a>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card h-100 shadow-sm">
                    <div class="card-body text-center">
                        <h5 class="card-title">Stock Management</h5>
                        <p class="card-text">Handle stock operations: receive, move, view, and manage expiry.</p>
                        <a href="stockManagement.jsp" class="btn btn-dark">Manage Stock</a>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card h-100 shadow-sm">
                    <div class="card-body text-center">
                        <h5 class="card-title">Discount Management</h5>
                        <p class="card-text">Create and manage discounts for products.</p>
                        <a href="discountManagement.jsp" class="btn btn-dark">Manage Discounts</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>