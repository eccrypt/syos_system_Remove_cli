<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Store Billing</title>
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
            // Could refresh product availability in the billing interface
        }

        function handleOrderProcessed(data) {
            console.log('Order processed for product:', data.productCode, 'Quantity sold:', data.quantitySold);
            // Could update stock levels in the product table
        }

        function handleProductAdded(data) {
            console.log('New product added:', data.productCode, data.productName);
            // Could refresh the product list
        }

        function handleProductUpdated(data) {
            console.log('Product updated:', data.productCode, data.productName);
            // Could update product information in the table
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
                <h1 class="mb-4">Store Billing</h1>

        <c:if test="${not empty error}">
            <div class="alert alert-dark">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-dark">${message}</div>
        </c:if>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Search Product</h5>
            </div>
            <div class="card-body">
                <form action="billing" method="get" class="row g-3">
                    <div class="col-md-8">
                        <label class="form-label">Product Code or Name</label>
                        <input type="text" name="search" value="${param.search}" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-dark w-100">Search</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Products</h5>
            </div>
            <div class="card-body">
                <c:if test="${not empty products}">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Code</th>
                                    <th>Name</th>
                                    <th>Price</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="product" items="${products}">
                                    <c:if test="${empty param.search or product.code.contains(param.search) or product.name.toLowerCase().contains(param.search.toLowerCase())}">
                                        <tr>
                                            <td>${product.code}</td>
                                            <td>${product.name}</td>
                                            <td>${product.price}</td>
                                            <td>
                                                <form action="billing" method="post" class="d-inline">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="productCode" value="${product.code}">
                                                    <div class="input-group input-group-sm" style="width: 150px;">
                                                        <span class="input-group-text">Qty</span>
                                                        <input type="number" name="quantity" value="1" min="1" class="form-control" required>
                                                        <button type="submit" class="btn btn-dark btn-sm">Add</button>
                                                    </div>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
                <c:if test="${empty products}">
                    <p class="text-muted">No products available.</p>
                </c:if>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">
                <h5>Add Item by Code</h5>
            </div>
            <div class="card-body">
                <form action="billing" method="post" class="row g-3">
                    <input type="hidden" name="action" value="add">
                    <div class="col-md-6">
                        <label class="form-label">Product Code</label>
                        <input type="text" name="productCode" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Quantity</label>
                        <input type="number" name="quantity" min="1" class="form-control" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">&nbsp;</label>
                        <button type="submit" class="btn btn-dark w-100">Add Item</button>
                    </div>
                </form>
            </div>
        </div>

        <c:if test="${not empty billItems}">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Current Bill Items</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Subtotal</th>
                                    <th>Discount</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
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
                            </tbody>
                        </table>
                    </div>
                    <div class="alert alert-dark">
                        <strong>Total Due: </strong>
                        <c:set var="total" value="0"/>
                        <c:forEach var="item" items="${billItems}">
                            <c:set var="total" value="${total + item.totalPrice}"/>
                        </c:forEach>
                        ${total}
                    </div>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header">
                    <h5>Proceed to Payment</h5>
                </div>
                <div class="card-body">
                    <form action="billing" method="post" class="row g-3">
                        <input type="hidden" name="action" value="pay">
                        <div class="col-md-6">
                            <label class="form-label">Cash Tendered</label>
                            <input type="number" step="0.01" name="cashTendered" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-dark w-100">Pay and Print Bill</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <div class="text-center">
            <form action="billing" method="post">
                <input type="hidden" name="action" value="newBill">
                <button type="submit" class="btn btn-dark">Start New Bill</button>
            </form>
            </div>
        </div>
    </div>
</body>
</html>