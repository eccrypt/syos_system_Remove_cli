<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.repository.BillingRepository" %>
<%@ page import="com.syos.model.Bill" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String billIdParam = request.getParameter("billId");
    if (billIdParam != null) {
        try {
            int billId = Integer.parseInt(billIdParam);
            BillingRepository billingRepo = new BillingRepository();
            Bill bill = billingRepo.findById(billId);
            if (bill != null) {
                request.setAttribute("bill", bill);
            }
        } catch (Exception e) {
            // Handle error
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Bill Receipt</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Real-time updates via WebSocket
        let websocket = null;

        function connectWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + '/realtime-updates';

            websocket = new WebSocket(wsUrl);

            websocket.onopen = function(event) {
                console.log('WebSocket connected');
            };

            websocket.onmessage = function(event) {
                try {
                    const update = JSON.parse(event.data);
                    handleRealtimeUpdate(update);
                } catch (e) {
                    console.error('Error parsing WebSocket message:', e);
                }
            };

            websocket.onclose = function(event) {
                console.log('WebSocket disconnected, reconnecting...');
                setTimeout(connectWebSocket, 3000);
            };

            websocket.onerror = function(error) {
                console.error('WebSocket error:', error);
            };
        }

        function handleRealtimeUpdate(update) {
            console.log('Received real-time update:', update);
            // Receipt page - mostly informational, but good to stay connected
        }

        // Connect to WebSocket when page loads
        document.addEventListener('DOMContentLoaded', function() {
            connectWebSocket();
        });
    </script>
    <style>
        .receipt-container { max-width: 600px; margin: 0 auto; }
        .store-header { background: #007bff; color: white; padding: 20px; text-align: center; }
        .receipt-body { padding: 20px; }
        .total-row { border-top: 2px solid #333; padding-top: 10px; }
        .receipt-table th { background: white; }
    </style>
</head>
<body class="bg-white">
    <div class="container py-5">
        <div class="receipt-container">
            <div class="card shadow">
                <div class="store-header">
                    <h2 class="mb-1">SYOS ONLINE STORE</h2>
                    <p class="mb-0">Invoice</p>
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
                                    <td>${item.product.name} (${item.product.code})</td>
                                    <td class="text-center">${item.quantity}</td>
                                    <td class="text-end">Rs. ${item.product.price}</td>
                                    <td class="text-end">Rs. ${item.totalPrice}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot>
                            <tr class="total-row">
                                <td colspan="3" class="text-end fw-bold">Total Amount</td>
                                <td class="text-end fw-bold">Rs. ${bill.totalAmount}</td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end">Cash Tendered</td>
                                <td class="text-end">Rs. ${bill.cashTendered}</td>
                            </tr>
                            <tr>
                                <td colspan="3" class="text-end fw-bold">Change</td>
                                <td class="text-end fw-bold">Rs. ${bill.changeReturned}</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>

        <div class="text-center mt-4">
            <p class="text-success">Thank you for shopping with SYOS Online Store!</p>
            <a href="customerProducts.jsp" class="btn btn-primary me-2">Continue Shopping</a>
        </div>

    </div>
</body>
</html>