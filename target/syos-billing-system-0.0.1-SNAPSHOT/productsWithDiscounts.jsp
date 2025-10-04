<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.DiscountService" %>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.model.Discount" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    DiscountService discountService = new DiscountService();
    List<Product> products = discountService.getProductsWithActiveDiscounts(LocalDate.now());
    request.setAttribute("products", products);
    request.setAttribute("discountRepository", new com.syos.repository.DiscountRepository());
    request.setAttribute("today", LocalDate.now());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Products with Discounts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body class="bg-white">
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>
    <div class="d-flex">
        <div style="margin-left: 250px; width: calc(100% - 250px);">
            <div class="container py-5">
                <h1 class="mb-4">Products with Discounts</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-dark">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-dark">${message}</div>
        </c:if>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Assign Discount</h5>
                    </div>
                    <div class="card-body">
                        <form id="assignForm">
                            <input type="hidden" name="action" value="assignDiscount">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Discount ID</label>
                                <input type="number" name="discountId" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-dark">Assign Discount</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5>Current Discount Assignments</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Product Code</th>
                                <th>Product Name</th>
                                <th>Discount ID</th>
                                <th>Discount Name</th>
                                <th>Discount Type</th>
                                <th>Discount Value</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="product" items="${products}">
                                <c:set var="discounts" value="${discountRepository.findDiscountsByProductCode(product.code, today)}" />
                                <c:forEach var="discount" items="${discounts}">
                                    <tr>
                                        <td>${product.code}</td>
                                        <td>${product.name}</td>
                                        <td>${discount.id}</td>
                                        <td>${discount.name}</td>
                                        <td>${discount.type}</td>
                                        <td>${discount.value}</td>
                                        <td>
                                            <button class="btn btn-dark btn-sm unassign-btn" data-product="${product.code}" data-discount="${discount.id}">Unassign</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <c:if test="${empty products}">
                    <p class="text-muted">No products with active discounts found.</p>
                </c:if>
            </div>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            $('#assignForm, #unassignForm').on('submit', function(e) {
                e.preventDefault();
                var form = $(this);
                var formData = form.serialize();
                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: formData,
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });

            $('.unassign-btn').on('click', function() {
                var btn = $(this);
                var productCode = btn.data('product');
                var discountId = btn.data('discount');
                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: {
                        action: 'unassignDiscount',
                        productCode: productCode,
                        discountId: discountId
                    },
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });
        });
    </script>
</body>
</html>