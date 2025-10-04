<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Report Menu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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