<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.model.BillItem" %>
<%@ page import="java.util.List" %>
<%
    @SuppressWarnings("unchecked")
    List<BillItem> billItems = (List<BillItem>) request.getAttribute("billItems");
    Double total = (Double) request.getAttribute("total");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout - SYOS System</title>
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
                default:
                    console.log('Unknown update type:', update.eventType);
            }
        }

        function handleStockUpdate(data) {
            console.log('Stock updated for product:', data.productCode, 'Online:', data.onlineQuantity);

            if (data.onlineQuantity === 0) {
                alert('Warning: ' + data.productCode + ' is now out of stock! Please review your cart.');
                // Optionally disable checkout or redirect to cart
            }
        }

        function handleOrderProcessed(data) {
            console.log('Order processed for product:', data.productCode, 'Quantity sold:', data.quantitySold);
            // Could show notification that stock has changed
        }

        // Connect to WebSocket when page loads
        document.addEventListener('DOMContentLoaded', function() {
            connectWebSocket();
        });
    </script>
</head>
<body class="bg-white">
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <span class="navbar-brand">SYOS Customer Portal</span>
            <div class="d-flex">
                <span class="navbar-text me-3">
                    Welcome, <%= session.getAttribute("userName") %> (Customer)
                </span>
                <a href="cart.jsp" class="btn btn-outline-light btn-sm me-2">
                    <i class="bi bi-arrow-left"></i> Back to Cart
                </a>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h2>Checkout</h2>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                        <% } %>

                        <h4>Order Summary</h4>
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (BillItem item : billItems) { %>
                                    <tr>
                                        <td><%= item.getProduct().getName() %> (<%= item.getProduct().getCode() %>)</td>
                                        <td><%= item.getQuantity() %></td>
                                        <td>Rs. <%= item.getProduct().getPrice() %></td>
                                        <td>Rs. <%= item.getTotalPrice() %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>

                        <div class="d-flex justify-content-between">
                            <h4>Total: Rs. <%= total %></h4>
                        </div>

                        <div class="mt-4">
                            <button id="confirmPaymentBtn" class="btn btn-success btn-lg w-100" onclick="processCheckout()">
                                <span id="btnText">Confirm Payment</span>
                                <div id="loadingSpinner" class="spinner-border spinner-border-sm ms-2 d-none" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                            </button>
                        </div>

                        <script>
                        function processCheckout() {
                            const btn = document.getElementById('confirmPaymentBtn');
                            const btnText = document.getElementById('btnText');
                            const spinner = document.getElementById('loadingSpinner');

                            // Disable button and show loading
                            btn.disabled = true;
                            btnText.textContent = 'Processing...';
                            spinner.classList.remove('d-none');

                            // Submit async request
                            fetch('async-customer-checkout', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                },
                                body: 'action=processCheckout'
                            })
                            .then(response => response.json())
                            .then(data => {
                                if (data.status === 'success') {
                                    // Redirect to receipt page
                                    window.location.href = 'customerBillReceipt.jsp?billId=' + data.data.billId;
                                } else {
                                    // Show error
                                    alert('Checkout failed: ' + (data.message || 'Unknown error'));
                                    // Re-enable button
                                    btn.disabled = false;
                                    btnText.textContent = 'Confirm Payment';
                                    spinner.classList.add('d-none');
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                                alert('Checkout failed: Network error');
                                // Re-enable button
                                btn.disabled = false;
                                btnText.textContent = 'Confirm Payment';
                                spinner.classList.add('d-none');
                            });
                        }
                        </script>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>