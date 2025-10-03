<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Products with Discounts</title>
</head>
<body>
    <h1>All Products with Discounts</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <table border="1">
        <tr>
            <th>Product Code</th>
            <th>Product Name</th>
            <th>Discount ID</th>
            <th>Discount Name</th>
            <th>Discount Type</th>
            <th>Discount Value</th>
        </tr>
        <c:forEach var="product" items="${products}">
            <c:set var="discounts" value="${discountRepository.findDiscountsByProductCode(product.code, today)}" />
            <c:if test="${not empty discounts}">
                <c:forEach var="discount" items="${discounts}">
                    <tr>
                        <td>${product.code}</td>
                        <td>${product.name}</td>
                        <td>${discount.id}</td>
                        <td>${discount.name}</td>
                        <td>${discount.type}</td>
                        <td>${discount.value}</td>
                    </tr>
                </c:forEach>
            </c:if>
        </c:forEach>
    </table>
</body>
</html>