<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.ProductService" %>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.model.Product" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    ProductService productService = new ProductService();
    List<Product> products = productService.getAllProducts();
    request.setAttribute("products", products);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Product Management</title>
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
                <h1 class="mb-4">Product Management</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-dark">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-dark">${message}</div>
        </c:if>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Add New Product</h5>
            </div>
            <div class="card-body">
                <form id="addProductForm" class="row g-3">
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
                        <button type="submit" class="btn btn-dark">Add Product</button>
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
                                    <tr data-code="${product.code}">
                                        <td>${product.code}</td>
                                        <td contenteditable="true" class="editable-name">${product.name}</td>
                                        <td contenteditable="true" class="editable-price">${product.price}</td>
                                        <td>
                                            <button class="btn btn-dark btn-sm save-btn" style="display:none;">Save</button>
                                            <button class="btn btn-secondary btn-sm edit-btn">Edit</button>
                                            <form action="inventory" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="deleteProduct">
                                                <input type="hidden" name="code" value="${product.code}">
                                                <button type="submit" class="btn btn-dark btn-sm" onclick="return confirm('Are you sure you want to delete this product?');">Delete</button>
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
                            <button type="submit" class="btn btn-dark">Update Product</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            $('#addProductForm').on('submit', function(e) {
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
                            form[0].reset();
                            location.reload(); // Reload to show updated product list
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });

            $('.edit-btn').on('click', function() {
                var row = $(this).closest('tr');
                row.find('.editable-name, .editable-price').attr('contenteditable', 'true').addClass('bg-light');
                row.find('.save-btn').show();
                row.find('.edit-btn').hide();
            });

            $('.save-btn').on('click', function() {
                var row = $(this).closest('tr');
                var code = row.data('code');
                var name = row.find('.editable-name').text().trim();
                var price = parseFloat(row.find('.editable-price').text().trim());

                if (isNaN(price)) {
                    alert('Invalid price');
                    return;
                }

                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: {
                        action: 'updateProduct',
                        code: code,
                        newName: name,
                        newPrice: price
                    },
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            row.find('.editable-name, .editable-price').attr('contenteditable', 'false').removeClass('bg-light');
                            row.find('.save-btn').hide();
                            row.find('.edit-btn').show();
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