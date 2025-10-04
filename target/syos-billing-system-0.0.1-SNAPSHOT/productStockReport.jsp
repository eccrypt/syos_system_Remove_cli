<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.dto.ProductStockReportItemDTO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <title>Product Stock Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .summary { font-weight: bold; font-size: 1.1em; margin: 20px 0; padding: 10px; background-color: #f9f9f9; }
        .back-link { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="back-link">
        <a href="reports.jsp">← Back to Reports Menu</a>
    </div>

    <h1>Product Stock Report (Combined Shelf & Inventory)</h1>

    <%
        List<ProductStockReportItemDTO> reportItems = (List<ProductStockReportItemDTO>) request.getAttribute("reportItems");

        if (reportItems != null && !reportItems.isEmpty()) {
    %>
        <table>
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

        <%
            int totalProducts = reportItems.size();
            int totalShelfQuantity = 0;
            int totalInventoryQuantity = 0;
            for (com.syos.dto.ProductStockReportItemDTO item : reportItems) {
                totalShelfQuantity += item.getTotalQuantityOnShelf();
                totalInventoryQuantity += item.getTotalQuantityInInventory();
            }
        %>

        <div class="summary">
            Summary: <%= totalProducts %> Products | Total Shelf Quantity: <%= totalShelfQuantity %> | Total Inventory Quantity: <%= totalInventoryQuantity %>
        </div>
    <%
        } else {
    %>
        <p>No product stock data found.</p>
    <%
        }
    %>
</body>
</html>