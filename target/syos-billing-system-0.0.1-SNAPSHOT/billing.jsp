<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Store Billing</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">Store Billing</h1>
        <a href="index.jsp" class="btn btn-light mb-4">Back to Main Menu</a>

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
</body>
</html>