<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>View All Products</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
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

            switch(update.eventType) {
                case 'STOCK_UPDATE':
                    handleStockUpdate(update.data);
                    break;
                case 'ORDER_PROCESSED':
                    handleOrderProcessed(update.data);
                    break;
                case 'PRODUCT_ADDED':
                    handleProductAdded(update.data);
                    break;
                case 'PRODUCT_UPDATED':
                    handleProductUpdated(update.data);
                    break;
                default:
                    console.log('Unknown update type:', update.eventType);
            }
        }

        function handleStockUpdate(data) {
            console.log('Stock updated for product:', data.productCode, 'Shelf:', data.shelfQuantity, 'Online:', data.onlineQuantity);
        }

        function handleOrderProcessed(data) {
            console.log('Order processed for product:', data.productCode, 'Quantity sold:', data.quantitySold);
        }

        function handleProductAdded(data) {
            console.log('New product added:', data.productCode, data.productName);
            // Could refresh the product list
        }

        function handleProductUpdated(data) {
            console.log('Product updated:', data.productCode, data.productName);
            // Could update the product in the table
        }

        // Connect to WebSocket when page loads
        document.addEventListener('DOMContentLoaded', function() {
            connectWebSocket();
        });
    </script>
</head>
<body class="bg-white">
    <%@ include file="sidebar.jsp" %>
    <%@ include file="header.jsp" %>
    <div class="d-flex">
        <div style="margin-left: 250px; width: calc(100% - 250px);">
            <div class="container py-5">
                <h1 class="mb-4">All Registered Products</h1>

        <c:if test="${not empty products}">
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Name</th>
                            <th>Price</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="product" items="${products}">
                            <tr>
                                <td>${product.code}</td>
                                <td>${product.name}</td>
                                <td>${product.price}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
        <c:if test="${empty products}">
            <p class="text-muted">No products found.</p>
        </c:if>
            </div>
        </div>
    </div>
</body>
</html>