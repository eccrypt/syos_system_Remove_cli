<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Stock Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">Stock Management</h1>
        <a href="inventory.jsp" class="btn btn-secondary mb-4">Back to Inventory Dashboard</a>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Receive Stock</h5>
                    </div>
                    <div class="card-body">
                        <form action="inventory" method="post">
                            <input type="hidden" name="action" value="receiveStock">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Quantity</label>
                                <input type="number" name="quantity" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Purchase Date</label>
                                <input type="date" name="purchaseDate" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Expiry Date</label>
                                <input type="date" name="expiryDate" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-primary">Receive Stock</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Move to Shelf</h5>
                    </div>
                    <div class="card-body">
                        <form action="inventory" method="post">
                            <input type="hidden" name="action" value="moveToShelf">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="code" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Quantity</label>
                                <input type="number" name="quantity" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-primary">Move to Shelf</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5>All Inventory Stocks</h5>
                <form action="inventory" method="post" class="d-inline">
                    <input type="hidden" name="action" value="viewAllInventoryStocks">
                    <button type="submit" class="btn btn-outline-primary btn-sm">Refresh</button>
                </form>
            </div>
            <div class="card-body">
                <c:if test="${not empty productCodes}">
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
                                    <th>Actions</th>
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
                                            <td></td>
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
                                                <td></td>
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
                                                <td>
                                                    <form action="inventory" method="post" class="d-inline">
                                                        <input type="hidden" name="action" value="moveToShelf">
                                                        <input type="hidden" name="code" value="${productCode}">
                                                        <input type="number" name="quantity" min="1" max="${batch.quantityRemaining}" placeholder="Qty" class="form-control form-control-sm d-inline-block" style="width: 80px;" required>
                                                        <button type="submit" class="btn btn-warning btn-sm">Move</button>
                                                    </form>
                                                    <form action="inventory" method="post" class="d-inline">
                                                        <input type="hidden" name="action" value="discardBatch">
                                                        <input type="hidden" name="batchId" value="${batch.id}">
                                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Discard this batch?');">Discard</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <p class="text-muted mt-2">Note: 'Shelf Qty' is the total quantity on the shelf. 'Batch Rem. Qty' is stock remaining in back-store batches.</p>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>