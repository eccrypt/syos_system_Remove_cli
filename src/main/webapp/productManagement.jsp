<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.repository.ProductRepository" %>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.model.Product" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    ProductRepository productRepository = new ProductRepository();
    List<Product> products = productRepository.findAll();
    request.setAttribute("products", products);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Product Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">Product Management</h1>
        <a href="inventory.jsp" class="btn btn-secondary mb-4">Back to Inventory Dashboard</a>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Add New Product</h5>
            </div>
            <div class="card-body">
                <form action="inventory" method="post" class="row g-3">
                    <input type="hidden" name="action" value="addProduct">
                    <div class="col-md-4">
                        <label class="form-label">Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Code</label>
                        <input type="text" name="code" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Price</label>
                        <input type="number" step="0.01" name="price" class="form-control" required>
                    </div>
                    <div class="col-12">
                        <button type="submit" class="btn btn-primary">Add Product</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5>All Products</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty products}">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Code</th>
                                    <th>Name</th>
                                    <th>Price</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="product" items="${products}">
                                    <tr>
                                        <td>${product.code}</td>
                                        <td>${product.name}</td>
                                        <td>${product.price}</td>
                                        <td>
                                            <a href="?action=editProduct&code=${product.code}" class="btn btn-warning btn-sm">Edit</a>
                                            <form action="inventory" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="deleteProduct">
                                                <input type="hidden" name="code" value="${product.code}">
                                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this product?');">Delete</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
                <c:if test="${empty products}">
                    <p class="text-muted">No products found.</p>
                </c:if>
            </div>
        </div>

        <c:if test="${not empty editProduct}">
            <div class="card mt-4">
                <div class="card-header">
                    <h5>Edit Product</h5>
                </div>
                <div class="card-body">
                    <form action="inventory" method="post" class="row g-3">
                        <input type="hidden" name="action" value="updateProduct">
                        <div class="col-md-4">
                            <label class="form-label">Code</label>
                            <input type="text" name="code" class="form-control" value="${editProduct.code}" readonly>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">New Name</label>
                            <input type="text" name="newName" class="form-control" value="${editProduct.name}" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">New Price</label>
                            <input type="number" step="0.01" name="newPrice" class="form-control" value="${editProduct.price}" required>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary">Update Product</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>
    </div>
</body>
</html>