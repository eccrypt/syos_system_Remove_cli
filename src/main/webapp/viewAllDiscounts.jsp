<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Discounts</title>
</head>
<body>
    <h1>All Available Discounts</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <c:if test="${empty discounts}">
        <p>No discounts have been created yet.</p>
    </c:if>
    <c:if test="${not empty discounts}">
        <table border="1">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Type</th>
                <th>Value</th>
                <th>Start Date</th>
                <th>End Date</th>
            </tr>
            <c:forEach var="discount" items="${discounts}">
                <tr>
                    <td>${discount.id}</td>
                    <td>${discount.name}</td>
                    <td>${discount.type == 'PERCENT' ? 'Percentage' : 'Fixed Amount'}</td>
                    <td>${discount.type == 'PERCENT' ? discount.value + '%' : discount.value}</td>
                    <td>${discount.start}</td>
                    <td>${discount.end}</td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
</body>
</html>