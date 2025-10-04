<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Online Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">Online Store</h1>
        <a href="index.jsp" class="btn btn-secondary mb-4">Back to Main Menu</a>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Browse Products</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty products}">
                    <div class="row">
                        <c:forEach var="product" items="${products}">
                            <div class="col-md-4 mb-3">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <h5 class="card-title">${product.name}</h5>
                                        <p class="card-text">Code: ${product.code}</p>
                                        <p class="card-text">Price: ${product.price}</p>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${empty products}">
                    <p class="text-muted">No products available.</p>
                </c:if>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Search Product by Code</h5>
            </div>
            <div class="card-body">
                <form action="onlineStore" method="post" class="row g-3">
                    <div class="col-md-8">
                        <label class="form-label">Product Code</label>
                        <input type="text" name="code" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-primary w-100">Search</button>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty searchedProduct}">
            <div class="alert alert-success">
                Found: ${searchedProduct.name} (${searchedProduct.code}) — ${searchedProduct.price}
            </div>
        </c:if>
        <c:if test="${empty searchedProduct and not empty param.code}">
            <div class="alert alert-warning">
                Product not found.
            </div>
        </c:if>
    </div>
</body>
</html>