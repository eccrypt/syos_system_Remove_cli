<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.dto.ProductStockReportItemDTO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <title>Product Stock Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-light">
    <div class="container py-5">
        <a href="reports.jsp" class="btn btn-secondary mb-4">Back to Reports Menu</a>

        <h1 class="text-center mb-4">Product Stock Report (Combined Shelf & Inventory)</h1>

        <%
            List<ProductStockReportItemDTO> reportItems = (List<ProductStockReportItemDTO>) request.getAttribute("reportItems");

            if (reportItems != null && !reportItems.isEmpty()) {
        %>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Product Name</th>
                            <th>Shelf Qty</th>
                            <th>Inv. Qty</th>
                            <th>Earliest Shelf Exp.</th>
                            <th>Earliest Inv. Exp.</th>
                            <th>Exp. Batches</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (ProductStockReportItemDTO item : reportItems) {
                                String earliestShelfExpiry = (item.getEarliestExpiryDateOnShelf() != null)
                                    ? item.getEarliestExpiryDateOnShelf().format(DateTimeFormatter.ISO_DATE)
                                    : "N/A";
                                String earliestInvExpiry = (item.getEarliestExpiryDateInInventory() != null)
                                    ? item.getEarliestExpiryDateInInventory().format(DateTimeFormatter.ISO_DATE)
                                    : "N/A";
                        %>
                            <tr>
                                <td><%= item.getProductCode() %></td>
                                <td><%= item.getProductName() %></td>
                                <td><%= item.getTotalQuantityOnShelf() %></td>
                                <td><%= item.getTotalQuantityInInventory() %></td>
                                <td><%= earliestShelfExpiry %></td>
                                <td><%= earliestInvExpiry %></td>
                                <td><%= item.getNumberOfExpiringBatches() %></td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <%
                int totalProducts = reportItems.size();
                int totalShelfQuantity = 0;
                int totalInventoryQuantity = 0;
                for (com.syos.dto.ProductStockReportItemDTO item : reportItems) {
                    totalShelfQuantity += item.getTotalQuantityOnShelf();
                    totalInventoryQuantity += item.getTotalQuantityInInventory();
                }
            %>

            <div class="alert alert-info">
                <strong>Summary: <%= totalProducts %> Products | Total Shelf Quantity: <%= totalShelfQuantity %> | Total Inventory Quantity: <%= totalInventoryQuantity %></strong>
            </div>
        <%
            } else {
        %>
            <p class="text-muted">No product stock data found.</p>
        <%
            }
        %>
    </div>
</body>
</html>