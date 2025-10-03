<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>View All Products</title>
</head>
<body>
    <h1>All Registered Products</h1>
    <a href="inventory">Back to Inventory Menu</a>

    <c:if test="${not empty products}">
        <table border="1">
            <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Price</th>
            </tr>
            <c:forEach var="product" items="${products}">
                <tr>
                    <td>${product.code}</td>
                    <td>${product.name}</td>
                    <td>${product.price}</td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty products}">
        <p>No products found.</p>
    </c:if>
</body>
</html>