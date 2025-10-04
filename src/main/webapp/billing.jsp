<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Store Billing</title>
</head>
<body>
    <h1>Store Billing</h1>
    <a href="index.jsp">Back to Main Menu</a>

    <c:if test="${not empty error}">
        <p style="color: red;">${error}</p>
    </c:if>
    <c:if test="${not empty message}">
        <p style="color: green;">${message}</p>
    </c:if>

    <h2>Search Product</h2>
    <form action="billing" method="get">
        <label>Product Code or Name: <input type="text" name="search" value="${param.search}"></label>
        <input type="submit" value="Search">
    </form>

    <h2>Products</h2>
    <c:if test="${not empty products}">
        <table border="1">
            <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Price</th>
                <th>Action</th>
            </tr>
            <c:forEach var="product" items="${products}">
                <c:if test="${empty param.search or product.code.contains(param.search) or product.name.toLowerCase().contains(param.search.toLowerCase())}">
                    <tr>
                        <td>${product.code}</td>
                        <td>${product.name}</td>
                        <td>${product.price}</td>
                        <td>
                            <form action="billing" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="productCode" value="${product.code}">
                                <label>Qty: <input type="number" name="quantity" value="1" min="1" required></label>
                                <input type="submit" value="Add to Bill">
                            </form>
                        </td>
                    </tr>
                </c:if>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty products}">
        <p>No products available.</p>
    </c:if>

    <h2>Add Item by Code</h2>
    <form action="billing" method="post">
        <input type="hidden" name="action" value="add">
        <label>Product Code: <input type="text" name="productCode" required></label><br>
        <label>Quantity: <input type="number" name="quantity" min="1" required></label><br>
        <input type="submit" value="Add Item">
    </form>

    <c:if test="${not empty billItems}">
        <h2>Current Bill Items</h2>
        <table border="1">
            <tr>
                <th>Product</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th>Subtotal</th>
                <th>Discount</th>
                <th>Total</th>
            </tr>
            <c:forEach var="item" items="${billItems}">
                <tr>
                    <td>${item.product.name}</td>
                    <td>${item.quantity}</td>
                    <td>${item.product.price}</td>
                    <td>${item.product.price * item.quantity}</td>
                    <td>${item.discountAmount}</td>
                    <td>${item.totalPrice}</td>
                </tr>
            </c:forEach>
        </table>
        <p>Total Due: <c:set var="total" value="0"/>
            <c:forEach var="item" items="${billItems}">
                <c:set var="total" value="${total + item.totalPrice}"/>
            </c:forEach>
            ${total}
        </p>

        <h2>Proceed to Payment</h2>
        <form action="billing" method="post">
            <input type="hidden" name="action" value="pay">
            <label>Cash Tendered: <input type="number" step="0.01" name="cashTendered" required></label><br>
            <input type="submit" value="Pay and Print Bill">
        </form>
    </c:if>

    <form action="billing" method="post">
        <input type="hidden" name="action" value="newBill">
        <input type="submit" value="Start New Bill">
    </form>
</body>
</html>