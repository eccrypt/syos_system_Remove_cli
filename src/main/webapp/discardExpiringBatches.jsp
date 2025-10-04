<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Discard Expiring Batches</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">Batches Expiring in Next ${days} Days</h1>
        <a href="inventory" class="btn btn-light mb-4">Back to Inventory Menu</a>

        <c:if test="${empty batches}">
            <p class="text-muted">No stock batches found expiring within ${days} days.</p>
        </c:if>
        <c:if test="${not empty batches}">
            <div class="table-responsive mb-4">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Batch ID</th>
                            <th>Product Code</th>
                            <th>Expiry Date</th>
                            <th>Purch Date</th>
                            <th>Remaining Qty</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="batch" items="${batches}">
                            <tr>
                                <td>${batch.id}</td>
                                <td>${batch.productCode}</td>
                                <td>${batch.expiryDate}</td>
                                <td>${batch.purchaseDate}</td>
                                <td>${batch.quantityRemaining}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <h2>Discard Batch</h2>
            <form action="inventory" method="post" class="row g-3">
                <input type="hidden" name="action" value="discardExpiringBatches">
                <input type="hidden" name="days" value="${days}">
                <div class="col-md-5">
                    <label class="form-label">Batch ID</label>
                    <input type="number" name="batchId" class="form-control" required>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Quantity to Discard (0 for all)</label>
                    <input type="number" name="quantity" class="form-control" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <button type="submit" class="btn btn-dark w-100">Discard Batch</button>
                </div>
            </form>
        </c:if>
    </div>
</body>
</html>