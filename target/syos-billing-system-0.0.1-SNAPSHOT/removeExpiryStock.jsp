<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Remove Close to Expiry Stock</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">Products with Batches Expiring in Next ${days} Days</h1>
        <a href="inventory" class="btn btn-light mb-4">Back to Inventory Menu</a>

        <c:if test="${empty expiringProducts}">
            <p class="text-muted">No products found with batches expiring within ${days} days.</p>
        </c:if>
        <c:if test="${not empty expiringProducts}">
            <ul class="list-group mb-4">
                <c:forEach var="productCode" items="${expiringProducts}">
                    <li class="list-group-item">
                        <strong>${productCode}</strong> (Shelf Qty: ${stockService.getQuantityOnShelf(productCode)})
                        <ul class="list-group list-group-flush">
                            <c:forEach var="batch" items="${stockService.getExpiringBatchesForProduct(productCode, days)}">
                                <li class="list-group-item">Batch ID: ${batch.id}, Exp. Date: ${batch.expiryDate}, Remaining Qty: ${batch.quantityRemaining}</li>
                            </c:forEach>
                        </ul>
                    </li>
                </c:forEach>
            </ul>

            <h2>Remove from Shelf</h2>
            <form action="inventory" method="post" class="row g-3">
                <input type="hidden" name="action" value="removeCloseToExpiryStock">
                <div class="col-md-6">
                    <label class="form-label">Product Code</label>
                    <input type="text" name="productCode" class="form-control" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Quantity to Remove</label>
                    <input type="number" name="quantity" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <button type="submit" class="btn btn-dark w-100">Remove Stock</button>
                </div>
            </form>
        </c:if>
    </div>
</body>
</html>