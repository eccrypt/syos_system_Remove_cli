<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Expiring Batches</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>
    <div class="d-flex">
        <div style="margin-left: 250px; width: calc(100% - 250px);">
            <div class="container py-5">
                <h1 class="mb-4">Batches Expiring in Next ${days} Days</h1>

        <div class="table-responsive">
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
        </div>
    </div>
</body>
</html>