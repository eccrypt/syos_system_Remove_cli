<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Discounts</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">All Available Discounts</h1>
        <a href="inventory" class="btn btn-light mb-4">Back to Inventory Menu</a>

        <c:if test="${empty discounts}">
            <p class="text-muted">No discounts have been created yet.</p>
        </c:if>
        <c:if test="${not empty discounts}">
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Value</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="discount" items="${discounts}">
                            <tr>
                                <td>${discount.id}</td>
                                <td>${discount.name}</td>
                                <td>${discount.type == 'PERCENT' ? 'Percentage' : 'Fixed Amount'}</td>
                                <td><c:if test="${discount.type == 'PERCENT'}">${discount.value}%</c:if><c:if test="${discount.type != 'PERCENT'}">${discount.value}</c:if></td>
                                <td>${discount.start}</td>
                                <td>${discount.end}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
</body>
</html>