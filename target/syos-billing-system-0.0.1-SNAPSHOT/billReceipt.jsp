<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Bill Receipt</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .receipt-container { max-width: 600px; margin: 0 auto; }
        .store-header { background: #2c3e50; color: white; padding: 20px; text-align: center; }
        .receipt-body { padding: 20px; }
        .total-row { border-top: 2px solid #333; padding-top: 10px; }
        .receipt-table th { background: #f8f9fa; }
    </style>
</head>
<body class="bg-light">
    <div class="container py-5">
        <div class="receipt-container">
            <div class="card shadow">
                <div class="store-header">
                    <h2 class="mb-1">SYOS SUPERMARKET</h2>
                    <p class="mb-0">Sales Receipt</p>
                </div>

                <div class="receipt-body">
                    <div class="row mb-3">
                        <div class="col-6">
                            <strong>Receipt #:</strong> ${bill.serialNumber}
                        </div>
                        <div class="col-6 text-end">
                            <strong>Date:</strong> ${bill.billDate}
                        </div>
                    </div>

                    <table class="table table-borderless receipt-table">
                        <thead>
                            <tr>
                                <th>Item</th>
                                <th class="text-center">Qty</th>
                                <th class="text-end">Price</th>
                                <th class="text-end">Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${bill.items}">
                                <tr>
                                    <td>
                                        <strong>${item.product.name}</strong>
                                        <br><small class="text-muted">Code: ${item.product.code}</small>
                                        <c:if test="${item.discountAmount > 0}">
                                            <br><small class="text-danger">Discount: -${item.discountAmount}</small>
                                        </c:if>
                                    </td>
                                    <td class="text-center">${item.quantity}</td>
                                    <td class="text-end">${item.product.price}</td>
                                    <td class="text-end">
                                        <c:if test="${item.discountAmount > 0}">
                                            <span class="text-decoration-line-through text-muted">${item.product.price * item.quantity}</span><br>
                                            <strong>${item.totalPrice}</strong>
                                        </c:if>
                                        <c:if test="${item.discountAmount == 0}">
                                            ${item.product.price * item.quantity}
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot>
                            <tr class="total-row">
                                <td colspan="3" class="text-end fw-bold">TOTAL</td>
                                <td class="text-end fw-bold fs-5">${bill.totalAmount}</td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end">Cash Tendered</td>
                                <td class="text-end">${bill.cashTendered}</td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end fw-bold">Change</td>
                                <td class="text-end fw-bold">${bill.changeReturned}</td>
                            </tr>
                        </tfoot>
                    </table>

                    <div class="text-center mt-4">
                        <p class="mb-1 fw-bold">Thank you for shopping with us!</p>
                        <p class="text-muted small mb-0">Please visit us again</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="text-center mt-4">
            <a href="billing" class="btn btn-primary me-2">New Bill</a>
            <a href="index.jsp" class="btn btn-secondary">Main Menu</a>
        </div>

    </div>
</body>
</html>