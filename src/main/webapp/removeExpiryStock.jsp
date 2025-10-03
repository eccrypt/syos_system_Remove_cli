<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Remove Close to Expiry Stock</title>
</head>
<body>
    <h1>Products with Batches Expiring in Next ${days} Days</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <c:if test="${empty expiringProducts}">
        <p>No products found with batches expiring within ${days} days.</p>
    </c:if>
    <c:if test="${not empty expiringProducts}">
        <ul>
            <c:forEach var="productCode" items="${expiringProducts}">
                <li>${productCode} (Shelf Qty: ${inventoryManager.getQuantityOnShelf(productCode)})</li>
                <ul>
                    <c:forEach var="batch" items="${inventoryManager.getExpiringBatchesForProduct(productCode, days)}">
                        <li>Batch ID: ${batch.id}, Exp. Date: ${batch.expiryDate}, Remaining Qty: ${batch.quantityRemaining}</li>
                    </c:forEach>
                </ul>
            </c:forEach>
        </ul>

        <h2>Remove from Shelf</h2>
        <form action="inventory" method="post">
            <input type="hidden" name="action" value="removeCloseToExpiryStock">
            <label>Product Code: <input type="text" name="productCode" required></label><br>
            <label>Quantity to Remove: <input type="number" name="quantity" required></label><br>
            <input type="submit" value="Remove Stock">
        </form>
    </c:if>
</body>
</html>