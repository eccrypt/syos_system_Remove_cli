<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Expiring Batches</title>
</head>
<body>
    <h1>Batches Expiring in Next ${days} Days</h1>
    <a href="inventory">Back to Inventory Menu</a>

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
</body>
</html>