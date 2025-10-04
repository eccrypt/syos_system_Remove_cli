<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Inventory Stocks</title>
</head>
<body>
    <h1>All Inventory Stocks</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <table border="1">
        <tr>
            <th>Product Code</th>
            <th>Shelf Qty</th>
            <th>Batch ID</th>
            <th>Purch. Date</th>
            <th>Exp. Date</th>
            <th>Batch Rem. Qty</th>
        </tr>
        <c:forEach var="productCode" items="${productCodes}">
            <c:set var="quantityOnShelf" value="${inventoryManager.getQuantityOnShelf(productCode)}" />
            <c:set var="batches" value="${inventoryManager.getBatchesForProduct(productCode)}" />
            <c:if test="${batches.isEmpty() && quantityOnShelf == 0}">
                <tr>
                    <td>${productCode}</td>
                    <td>0</td>
                    <td>N/A</td>
                    <td>N/A</td>
                    <td>N/A</td>
                    <td>N/A</td>
                </tr>
            </c:if>
            <c:if test="${!batches.isEmpty() || quantityOnShelf > 0}">
                <c:if test="${batches.isEmpty()}">
                    <tr>
                        <td>${productCode}</td>
                        <td>${quantityOnShelf}</td>
                        <td>N/A</td>
                        <td>N/A</td>
                        <td>N/A</td>
                        <td>N/A</td>
                    </tr>
                </c:if>
                <c:forEach var="batch" items="${batches}" varStatus="status">
                    <tr>
                        <td>${productCode}</td>
                        <td>${status.first ? quantityOnShelf : ''}</td>
                        <td>${batch.id}</td>
                        <td>${batch.purchaseDate}</td>
                        <td>${batch.expiryDate}</td>
                        <td>${batch.quantityRemaining}</td>
                    </tr>
                </c:forEach>
            </c:if>
        </c:forEach>
    </table>
    <p>Note: 'Shelf Qty' is the total quantity on the shelf. 'Batch Rem. Qty' is stock remaining in back-store batches.</p>
</body>
</html>