<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Bill Receipt</title>
</head>
<body>
    <h1>Bill Receipt</h1>
    <a href="billing">New Bill</a> | <a href="index.jsp">Main Menu</a>

    <c:if test="${not empty bill}">
        <h2>Final Bill #${bill.serialNumber}</h2>
        <p>Date: ${bill.billDate}</p>
        <table border="1">
            <tr>
                <th>Item</th>
                <th>Qty</th>
                <th>Unit Price</th>
                <th>Subtotal</th>
                <th>Discount</th>
            </tr>
            <c:forEach var="item" items="${bill.items}">
                <tr>
                    <td>${item.product.name}</td>
                    <td>${item.quantity}</td>
                    <td>${item.product.price}</td>
                    <td>${item.product.price * item.quantity}</td>
                    <td>${item.discountAmount}</td>
                </tr>
                <c:if test="${item.discountAmount > 0}">
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>(Net) ${item.totalPrice}</td>
                </tr>
                </c:if>
            </c:forEach>
        </table>
        <p>Total: ${bill.totalAmount}</p>
        <p>Cash Tendered: ${bill.cashTendered}</p>
        <p>Change Returned: ${bill.changeReturned}</p>
        <p>Sales Invoice</p>
    </c:if>
</body>
</html>