<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>
    <div class="d-flex">
        <div style="margin-left: 250px; width: calc(100% - 250px);">
            <div class="container py-5">
                <h1 class="mb-4">Inventory Management Dashboard</h1>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>
                <c:if test="${not empty message}">
                    <div class="alert alert-success">${message}</div>
                </c:if>

                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-tag display-4 text-primary mb-3"></i>
                                <h5 class="card-title">Product Management</h5>
                                <p class="card-text">Manage products: add, view, edit, and delete products.</p>
                                <a href="productManagement.jsp" class="btn btn-dark">Manage Products</a>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-boxes display-4 text-success mb-3"></i>
                                <h5 class="card-title">Stock Management</h5>
                                <p class="card-text">Handle stock operations: receive, move, view, and manage expiry.</p>
                                <a href="stockManagement.jsp" class="btn btn-dark">Manage Stock</a>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-percent display-4 text-warning mb-3"></i>
                                <h5 class="card-title">Discounts</h5>
                                <p class="card-text">Create, edit, and delete discounts.</p>
                                <a href="discountManagement.jsp" class="btn btn-dark">Manage Discounts</a>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-tags display-4 text-info mb-3"></i>
                                <h5 class="card-title">Products with Discounts</h5>
                                <p class="card-text">View and manage product discount assignments.</p>
                                <a href="productsWithDiscounts.jsp" class="btn btn-dark">View Assignments</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mt-4">
                    <div class="col-md-6">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-receipt display-4 text-secondary mb-3"></i>
                                <h5 class="card-title">Billing</h5>
                                <p class="card-text">Create and process customer bills.</p>
                                <a href="billing" class="btn btn-dark">Start Billing</a>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="bi bi-graph-up display-4 text-danger mb-3"></i>
                                <h5 class="card-title">Reports</h5>
                                <p class="card-text">View sales reports and inventory analytics.</p>
                                <a href="reports.jsp" class="btn btn-dark">View Reports</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>