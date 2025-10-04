<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>SYOS Billing System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg navbar-dark bg-success">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">SYOS Billing System</a>
            <div class="d-flex">
                <span class="navbar-text me-3">
                    Welcome, <%= session.getAttribute("userName") %> (<%= session.getAttribute("userRole") %>)
                </span>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2 class="mb-4">Main Menu</h2>
                <div class="row">
                    <%
                        String userRole = (String) session.getAttribute("userRole");
                        boolean isAdmin = "ADMIN".equals(userRole);
                        boolean isStaff = "STAFF".equals(userRole);
                    %>

                    <% if (isAdmin || isStaff) { %>
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <h5 class="card-title">Store Billing</h5>
                                <p class="card-text">Process customer transactions and manage bills</p>
                                <a href="billing" class="btn btn-primary">Access Billing</a>
                            </div>
                        </div>
                    </div>
                    <% } %>


                    <% if (isAdmin || isStaff) { %>
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <h5 class="card-title">Inventory Management</h5>
                                <p class="card-text">Manage products, stock, and shelf operations</p>
                                <a href="inventory" class="btn btn-primary">Access Inventory</a>
                            </div>
                        </div>
                    </div>
                    <% } %>

                    <% if (isAdmin) { %>
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <h5 class="card-title">Reports</h5>
                                <p class="card-text">Generate sales and inventory reports</p>
                                <a href="reports" class="btn btn-primary">Access Reports</a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

                <% if (!isAdmin && !isStaff) { %>
                <div class="alert alert-warning text-center mt-4" role="alert">
                    You don't have access to any modules. Please contact your administrator.
                </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>