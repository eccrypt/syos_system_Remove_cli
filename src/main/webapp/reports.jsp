<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Report Menu</title>
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
            // Could update sales metrics
        }

        function handleProductAdded(data) {
            console.log('New product added:', data.productCode, data.productName);
        }

        function handleProductUpdated(data) {
            console.log('Product updated:', data.productCode, data.productName);
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
                <h1 class="mb-4">Report Menu</h1>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Daily Sales Report</h5>
                    </div>
                    <div class="card-body">
                        <form action="reports" method="post">
                            <input type="hidden" name="action" value="dailySales">
                            <div class="mb-3">
                                <label class="form-label">Date (YYYY-MM-DD)</label>
                                <input type="date" name="date" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-dark">Generate</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>All Transactions Report</h5>
                    </div>
                    <div class="card-body">
                        <form action="reports" method="post">
                            <input type="hidden" name="action" value="allTransactions">
                            <button type="submit" class="btn btn-dark">Generate</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Product Stock Report</h5>
                    </div>
                    <div class="card-body">
                        <form action="reports" method="post">
                            <input type="hidden" name="action" value="productStock">
                            <button type="submit" class="btn btn-dark">Generate</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Shelf & Inventory Analysis</h5>
                    </div>
                    <div class="card-body">
                        <form action="reports" method="post">
                            <input type="hidden" name="action" value="analysis">
                            <button type="submit" class="btn btn-dark">Generate</button>
                        </form>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </div>
</body>
</html>