<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.syos.service.DiscountService" %>
<%@ page import="com.syos.repository.DiscountRepository" %>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.model.Discount" %>
<%@ page import="com.syos.model.Product" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    DiscountService discountService = new DiscountService();
    List<Discount> discounts = discountService.getAllDiscounts();
    LocalDate today = LocalDate.now();
    List<Product> products = discountService.getProductsWithActiveDiscounts(today);
    request.setAttribute("discounts", discounts);
    request.setAttribute("products", products);
    request.setAttribute("discountRepository", new DiscountRepository()); // for compatibility
    request.setAttribute("today", today);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Discount Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <h1 class="text-center mb-4">Discount Management</h1>
        <a href="inventory.jsp" class="btn btn-light mb-4">Back to Inventory Dashboard</a>

        <c:if test="${not empty error}">
            <div class="alert alert-dark">${error}</div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-dark">${message}</div>
        </c:if>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Create Discount</h5>
                    </div>
                    <div class="card-body">
                        <form action="inventory" method="post">
                            <input type="hidden" name="action" value="createDiscount">
                            <div class="mb-3">
                                <label class="form-label">Name</label>
                                <input type="text" name="name" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="PERCENT">Percent</option>
                                    <option value="AMOUNT">Amount</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Value</label>
                                <input type="number" step="0.01" name="value" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Start Date</label>
                                <input type="date" name="startDate" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">End Date</label>
                                <input type="date" name="endDate" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-dark">Create Discount</button>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Assign/Unassign Discount</h5>
                    </div>
                    <div class="card-body">
                        <form id="assignForm" class="mb-3">
                            <input type="hidden" name="action" value="assignDiscount">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Discount ID</label>
                                <input type="number" name="discountId" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-dark">Assign Discount</button>
                        </form>
                        <form id="unassignForm">
                            <input type="hidden" name="action" value="unassignDiscount">
                            <div class="mb-3">
                                <label class="form-label">Product Code</label>
                                <input type="text" name="productCode" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Discount ID</label>
                                <input type="number" name="discountId" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-dark">Unassign Discount</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>All Discounts</h5>
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty discounts}">
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Type</th>
                                            <th>Value</th>
                                            <th>Start Date</th>
                                            <th>End Date</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="discount" items="${discounts}">
                                            <tr data-id="${discount.id}">
                                                <td>${discount.id}</td>
                                                <td contenteditable="true" class="editable-name">${discount.name}</td>
                                                <td>
                                                    <select class="form-select editable-type">
                                                        <option value="PERCENT" ${discount.type == 'PERCENT' ? 'selected' : ''}>Percentage</option>
                                                        <option value="AMOUNT" ${discount.type == 'AMOUNT' ? 'selected' : ''}>Fixed Amount</option>
                                                    </select>
                                                </td>
                                                <td contenteditable="true" class="editable-value">${discount.value}</td>
                                                <td><input type="date" class="form-control editable-start" value="${discount.start}"></td>
                                                <td><input type="date" class="form-control editable-end" value="${discount.end}"></td>
                                                <td>
                                                    <button class="btn btn-dark btn-sm save-btn" style="display:none;">Save</button>
                                                    <button class="btn btn-dark btn-sm edit-btn">Edit</button>
                                                    <button class="btn btn-dark btn-sm delete-btn">Delete</button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                        <c:if test="${empty discounts}">
                            <p class="text-muted">No discounts have been created yet.</p>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Products with Discounts</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Product Code</th>
                                        <th>Product Name</th>
                                        <th>Discount ID</th>
                                        <th>Discount Name</th>
                                        <th>Discount Type</th>
                                        <th>Discount Value</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="product" items="${products}">
                                        <c:set var="discounts" value="${discountRepository.findDiscountsByProductCode(product.code, today)}" />
                                        <c:forEach var="discount" items="${discounts}">
                                            <tr>
                                                <td>${product.code}</td>
                                                <td>${product.name}</td>
                                                <td>${discount.id}</td>
                                                <td>${discount.name}</td>
                                                <td>${discount.type}</td>
                                                <td>${discount.value}</td>
                                                <td>
                                                    <button class="btn btn-dark btn-sm unassign-btn" data-product="${product.code}" data-discount="${discount.id}">Unassign</button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <c:if test="${empty products}">
                            <p class="text-muted">No products with active discounts found.</p>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            $('#assignForm, #unassignForm').on('submit', function(e) {
                e.preventDefault();
                var form = $(this);
                var formData = form.serialize();
                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: formData,
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });

            $('.edit-btn').on('click', function() {
                var row = $(this).closest('tr');
                row.find('.editable-name, .editable-value').attr('contenteditable', 'true').addClass('bg-light');
                row.find('.editable-start, .editable-end, .editable-type').prop('disabled', false);
                row.find('.save-btn').show();
                row.find('.edit-btn').hide();
            });

            $('.save-btn').on('click', function() {
                var row = $(this).closest('tr');
                var id = row.data('id');
                var name = row.find('.editable-name').text().trim();
                var type = row.find('.editable-type').val();
                var value = parseFloat(row.find('.editable-value').text().trim());
                var startDate = row.find('.editable-start').val();
                var endDate = row.find('.editable-end').val();

                if (isNaN(value)) {
                    alert('Invalid value');
                    return;
                }

                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: {
                        action: 'updateDiscount',
                        discountId: id,
                        name: name,
                        type: type,
                        value: value,
                        startDate: startDate,
                        endDate: endDate
                    },
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            row.find('.editable-name, .editable-value').attr('contenteditable', 'false').removeClass('bg-light');
                            row.find('.editable-start, .editable-end, .editable-type').prop('disabled', true);
                            row.find('.save-btn').hide();
                            row.find('.edit-btn').show();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });

            $('.delete-btn').on('click', function() {
                if (!confirm('Are you sure you want to delete this discount?')) {
                    return;
                }
                var row = $(this).closest('tr');
                var id = row.data('id');
                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: {
                        action: 'deleteDiscount',
                        discountId: id
                    },
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });

            $('.unassign-btn').on('click', function() {
                var btn = $(this);
                var productCode = btn.data('product');
                var discountId = btn.data('discount');
                $.ajax({
                    url: 'inventory',
                    type: 'POST',
                    data: {
                        action: 'unassignDiscount',
                        productCode: productCode,
                        discountId: discountId
                    },
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.error);
                        }
                    },
                    error: function() {
                        alert('An error occurred.');
                    }
                });
            });
        });
    </script>
</body>
</html>