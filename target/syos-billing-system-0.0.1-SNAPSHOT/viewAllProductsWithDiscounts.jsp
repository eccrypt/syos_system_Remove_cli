<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Products with Discounts</title>
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
                <h1 class="mb-4">All Products with Discounts</h1>

        <c:set var="hasDiscounts" value="false" />
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
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="product" items="${products}">
                        <c:set var="discounts" value="${discountRepository.findDiscountsByProductCode(product.code, today)}" />
                        <c:if test="${not empty discounts}">
                            <c:set var="hasDiscounts" value="true" />
                            <c:forEach var="discount" items="${discounts}">
                                <tr>
                                    <td>${product.code}</td>
                                    <td>${product.name}</td>
                                    <td>${discount.id}</td>
                                    <td>${discount.name}</td>
                                    <td>${discount.type}</td>
                                    <td>${discount.value}</td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <c:if test="${not hasDiscounts}">
            <p class="text-muted">No products with active discounts found.</p>
        </c:if>
            </div>
        </div>
    </div>
</body>
</html>