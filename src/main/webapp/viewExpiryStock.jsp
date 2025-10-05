<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Expiry Stock Details</title>
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
            // Handle real-time updates for expiry stock view
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
                <h1 class="mb-4">Expiry Stock Details</h1>

        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Product Code</th>
                        <th>Shelf Qty</th>
                        <th>Batch ID</th>
                        <th>Purch. Date</th>
                        <th>Exp. Date</th>
                        <th>Batch Rem. Qty</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="productCode" items="${productCodes}">
                        <c:set var="quantityOnShelf" value="${inventoryManager.getQuantityOnShelf(productCode)}" />
                        <c:set var="batches" value="${inventoryManager.getBatchesForProduct(productCode)}" />
                        <c:if test="${batches.isEmpty() && quantityOnShelf == 0}">
                            <tr>
                                <td>${productCode}</td>
                                <td>0</td>
                                <td>N/A</td>
                                <td>N/A</td>
                                <td>N/A</td>
                                <td>N/A</td>
                            </tr>
                        </c:if>
                        <c:if test="${!batches.isEmpty() || quantityOnShelf > 0}">
                            <c:if test="${batches.isEmpty()}">
                                <tr>
                                    <td>${productCode}</td>
                                    <td>${quantityOnShelf}</td>
                                    <td>N/A</td>
                                    <td>N/A</td>
                                    <td>N/A</td>
                                    <td>N/A</td>
                                </tr>
                            </c:if>
                            <c:forEach var="batch" items="${batches}" varStatus="status">
                                <tr>
                                    <td>${productCode}</td>
                                    <td>${status.first ? quantityOnShelf : ''}</td>
                                    <td>${batch.id}</td>
                                    <td>${batch.purchaseDate}</td>
                                    <td>${batch.expiryDate}</td>
                                    <td>${batch.quantityRemaining}</td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <p class="text-muted mt-2">Note: 'Shelf Qty' is the total quantity on the shelf. 'Batch Rem. Qty' is stock remaining in back-store batches.</p>
            </div>
        </div>
    </div>
</body>
</html>