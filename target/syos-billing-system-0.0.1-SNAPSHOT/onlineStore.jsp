<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Online Store</title>
</head>
<body>
    <h1>Online Store</h1>
    <a href="index.jsp">Back to Main Menu</a>

    <h2>Browse Products</h2>
    <c:if test="${not empty products}">
        <ul>
            <c:forEach var="product" items="${products}">
                <li>${product.name} (${product.code}): ${product.price}</li>
            </c:forEach>
        </ul>
    </c:if>
    <c:if test="${empty products}">
        <p>No products available.</p>
    </c:if>

    <h2>Search Product by Code</h2>
    <form action="onlineStore" method="post">
        <label>Product Code: <input type="text" name="code" required></label>
        <input type="submit" value="Search">
    </form>

    <c:if test="${not empty searchedProduct}">
        <p>Found: ${searchedProduct.name} (${searchedProduct.code}) — ${searchedProduct.price}</p>
    </c:if>
    <c:if test="${empty searchedProduct and not empty param.code}">
        <p>Product not found.</p>
    </c:if>
</body>
</html>