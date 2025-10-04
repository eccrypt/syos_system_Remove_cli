<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Discard Expiring Batches</title>
</head>
<body>
    <h1>Batches Expiring in Next ${days} Days</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <c:if test="${empty batches}">
        <p>No stock batches found expiring within ${days} days.</p>
    </c:if>
    <c:if test="${not empty batches}">
        <table border="1">
            <tr>
                <th>Batch ID</th>
                <th>Product Code</th>
                <th>Expiry Date</th>
                <th>Purch Date</th>
                <th>Remaining Qty</th>
            </tr>
            <c:forEach var="batch" items="${batches}">
                <tr>
                    <td>${batch.id}</td>
                    <td>${batch.productCode}</td>
                    <td>${batch.expiryDate}</td>
                    <td>${batch.purchaseDate}</td>
                    <td>${batch.quantityRemaining}</td>
                </tr>
            </c:forEach>
        </table>

        <h2>Discard Batch</h2>
        <form action="inventory" method="post">
            <input type="hidden" name="action" value="discardExpiringBatches">
            <input type="hidden" name="days" value="${days}">
            <label>Batch ID: <input type="number" name="batchId" required></label><br>
            <label>Quantity to Discard (0 for all): <input type="number" name="quantity" required></label><br>
            <input type="submit" value="Discard Batch">
        </form>
    </c:if>
</body>
</html>