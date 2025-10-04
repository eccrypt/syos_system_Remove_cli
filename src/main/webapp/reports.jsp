<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Report Menu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">Report Menu</h1>
        <a href="index.jsp" class="btn btn-secondary mb-4">Back to Main Menu</a>

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
                            <button type="submit" class="btn btn-primary">Generate</button>
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
                            <button type="submit" class="btn btn-primary">Generate</button>
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
                            <button type="submit" class="btn btn-primary">Generate</button>
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
                            <button type="submit" class="btn btn-primary">Generate</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>