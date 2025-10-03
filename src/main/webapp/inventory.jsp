<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory Menu</title>
</head>
<body>
    <h1>Inventory Menu</h1>
    <a href="index.jsp">Back to Main Menu</a>

    <c:if test="${not empty error}">
        <p style="color: red;">${error}</p>
    </c:if>
    <c:if test="${not empty message}">
        <p style="color: green;">${message}</p>
    </c:if>

    <h2>Add New Product</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="addProduct">
        <label>Name: <input type="text" name="name" required></label><br>
        <label>Code: <input type="text" name="code" required></label><br>
        <label>Price: <input type="number" step="0.01" name="price" required></label><br>
        <input type="submit" value="Add Product">
    </form>

    <h2>View All Products</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewProducts">
        <input type="submit" value="View Products">
    </form>

    <!-- Other options can be added similarly -->
    <p>Other inventory operations (update, stock management, discounts) are not implemented in this web version for simplicity.</p>
</body>
</html>