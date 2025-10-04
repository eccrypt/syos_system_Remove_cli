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

    <h2>Update Product</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="updateProduct">
        <label>Product Code: <input type="text" name="code" required></label><br>
        <label>New Name: <input type="text" name="newName" required></label><br>
        <input type="submit" value="Update Product">
    </form>

    <h2>Receive Stock</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="receiveStock">
        <label>Product Code: <input type="text" name="productCode" required></label><br>
        <label>Quantity: <input type="number" name="quantity" required></label><br>
        <label>Purchase Date: <input type="date" name="purchaseDate" required></label><br>
        <label>Expiry Date: <input type="date" name="expiryDate" required></label><br>
        <input type="submit" value="Receive Stock">
    </form>

    <h2>Move to Shelf</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="moveToShelf">
        <label>Product Code: <input type="text" name="code" required></label><br>
        <label>Quantity: <input type="number" name="quantity" required></label><br>
        <input type="submit" value="Move to Shelf">
    </form>

    <h2>View Stock</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewStock">
        <label>Product Code (optional): <input type="text" name="productCode"></label><br>
        <input type="submit" value="View Stock">
    </form>

    <h2>View All Inventory Stocks</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewAllInventoryStocks">
        <input type="submit" value="View All Stocks">
    </form>

    <h2>View Expiry Stock</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewExpiryStock">
        <input type="submit" value="View Expiry Stock">
    </form>

    <h2>Remove Close to Expiry Stock</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="removeCloseToExpiryStock">
        <label>Days Threshold: <input type="number" name="days" required></label><br>
        <input type="submit" value="Show Expiring Products">
    </form>

    <h2>View Expiring Batches</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewExpiringBatches">
        <label>Days Threshold: <input type="number" name="days" required></label><br>
        <input type="submit" value="View Expiring Batches">
    </form>

    <h2>Discard Expiring Batches</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="discardExpiringBatches">
        <label>Days Threshold: <input type="number" name="days" required></label><br>
        <input type="submit" value="Show Batches to Discard">
    </form>

    <h2>Create Discount</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="createDiscount">
        <label>Name: <input type="text" name="name" required></label><br>
        <label>Type: <select name="type" required>
            <option value="PERCENT">Percent</option>
            <option value="AMOUNT">Amount</option>
        </select></label><br>
        <label>Value: <input type="number" step="0.01" name="value" required></label><br>
        <label>Start Date: <input type="date" name="startDate" required></label><br>
        <label>End Date: <input type="date" name="endDate" required></label><br>
        <input type="submit" value="Create Discount">
    </form>

    <h2>Assign Discount</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="assignDiscount">
        <label>Product Code: <input type="text" name="productCode" required></label><br>
        <label>Discount ID: <input type="number" name="discountId" required></label><br>
        <input type="submit" value="Assign Discount">
    </form>

    <h2>View All Discounts</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewAllDiscounts">
        <input type="submit" value="View Discounts">
    </form>

    <h2>View All Products with Discounts</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="viewAllProductsWithDiscounts">
        <input type="submit" value="View Products with Discounts">
    </form>

    <h2>Unassign Discount</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="action" value="unassignDiscount">
        <label>Product Code: <input type="text" name="productCode" required></label><br>
        <label>Discount ID: <input type="number" name="discountId" required></label><br>
        <input type="submit" value="Unassign Discount">
    </form>
</body>
</html>