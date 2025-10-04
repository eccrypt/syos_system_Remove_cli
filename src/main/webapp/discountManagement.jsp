<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.repository.DiscountRepository" %>
<%@ page import="com.syos.repository.ProductRepository" %>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.model.Discount" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    DiscountRepository discountRepository = new DiscountRepository();
    ProductRepository productRepository = new ProductRepository();
    List<Discount> discounts = discountRepository.findAll();
    List<Product> products = productRepository.findAll();
    LocalDate today = LocalDate.now();
    request.setAttribute("discounts", discounts);
    request.setAttribute("products", products);
    request.setAttribute("discountRepository", discountRepository);
    request.setAttribute("today", today);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Discount Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">Discount Management</h1>
        <a href="inventory.jsp" class="btn btn-secondary mb-4">Back to Inventory Dashboard</a>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Create Discount</h5>
                    </div>
                    <div class="card-body">
                        <form action="inventory" method="post">
                            <input type="hidden" name="action" value="createDiscount">
                            <div class="mb-3">
                                <label class="form-label">Name</label>
                                <input type="text" name="name" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="PERCENT">Percent</option>
                                    <option value="AMOUNT">Amount</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Value</label>
                                <input type="number" step="0.01" name="value" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Start Date</label>
                                <input type="date" name="startDate" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">End Date</label>
                                <input type="date" name="endDate" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-primary">Create Discount</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Assign/Unassign Discount</h5>
                    </div>
                    <div class="card-body">
                        <form action="inventory" method="post" class="mb-3">
                            <input type="hidden" name="action" value="assignDiscount">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Discount ID</label>
                                <input type="number" name="discountId" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-success">Assign Discount</button>
                        </form>
                        <form action="inventory" method="post">
                            <input type="hidden" name="action" value="unassignDiscount">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Discount ID</label>
                                <input type="number" name="discountId" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-warning">Unassign Discount</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>All Discounts</h5>
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty discounts}">
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Type</th>
                                            <th>Value</th>
                                            <th>Start Date</th>
                                            <th>End Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="discount" items="${discounts}">
                                            <tr>
                                                <td>${discount.id}</td>
                                                <td>${discount.name}</td>
                                                <td>${discount.type == 'PERCENT' ? 'Percentage' : 'Fixed Amount'}</td>
                                                <td><c:if test="${discount.type == 'PERCENT'}">${discount.value}%</c:if><c:if test="${discount.type != 'PERCENT'}">${discount.value}</c:if></td>
                                                <td>${discount.start}</td>
                                                <td>${discount.end}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                        <c:if test="${empty discounts}">
                            <p class="text-muted">No discounts have been created yet.</p>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Products with Discounts</h5>
                    </div>
                    <div class="card-body">
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
        </div>
    </div>
</body>
</html>