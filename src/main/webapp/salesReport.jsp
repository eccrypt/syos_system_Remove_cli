<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.syos.dto.BillReportDTO" %>
<%@ page import="com.syos.dto.BillItemReportDTO" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sales Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white">
    <div class="container py-5">
        <a href="reports.jsp" class="btn btn-light mb-4">Back to Reports Menu</a>

        <h1 class="text-center mb-4">Sales Report</h1>

        <%
            LocalDate reportDate = (LocalDate) request.getAttribute("reportDate");
            List<BillReportDTO> billReportDTOs = (List<BillReportDTO>) request.getAttribute("billReportDTOs");
            Double totalRevenue = (Double) request.getAttribute("totalRevenue");

            if (reportDate != null) {
        %>
            <h2 class="mb-4">Report for: <%= reportDate.format(DateTimeFormatter.ISO_DATE) %></h2>
        <%
            } else {
        %>
            <h2 class="mb-4">All Transactions Report</h2>
        <%
            }

            if (billReportDTOs != null && !billReportDTOs.isEmpty()) {
                for (BillReportDTO billDTO : billReportDTOs) {
        %>
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5>Bill #<%= billDTO.getSerialNumber() %> - Date: <%= billDTO.getBillDate().toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate().format(DateTimeFormatter.ISO_DATE) %> - Type: <%= billDTO.getTransactionType() %></h5>
                        </div>
                        <div class="card-body">
                            <p><strong>Cash Tendered:</strong> <%= String.format("%.2f", billDTO.getCashTendered()) %> | <strong>Change Returned:</strong> <%= String.format("%.2f", billDTO.getChangeReturned()) %></p>

                            <%
                                List<BillItemReportDTO> itemDTOs = billDTO.getItems();
                                if (itemDTOs != null && !itemDTOs.isEmpty()) {
                            %>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Item</th>
                                                <th>Qty</th>
                                                <th>Unit Price</th>
                                                <th>Subtotal</th>
                                                <th>Discount</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (BillItemReportDTO itemDTO : itemDTOs) {
                                            %>
                                                <tr>
                                                    <td><%= itemDTO.getProductName() %></td>
                                                    <td><%= itemDTO.getQuantity() %></td>
                                                    <td><%= String.format("%.2f", itemDTO.getUnitPrice()) %></td>
                                                    <td><%= String.format("%.2f", itemDTO.getCalculatedSubtotal()) %></td>
                                                    <td><%= String.format("%.2f", itemDTO.getDiscountAmount()) %></td>
                                                </tr>
                                            <%
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                                <p class="fw-bold fs-5">Total for Bill #<%= billDTO.getSerialNumber() %>: <%= String.format("%.2f", billDTO.getTotalAmount()) %></p>
                            <%
                                } else {
                            %>
                                <p>No items found for this bill.</p>
                            <%
                                }
                            %>
                        </div>
                    </div>
                <%
                    }
                %>

                <div class="alert alert-dark">
                    <%
                        if (reportDate != null) {
                    %>
                        <strong>Total revenue for <%= reportDate.format(DateTimeFormatter.ISO_DATE) %>: <%= String.format("%.2f", totalRevenue) %></strong>
                    <%
                        } else {
                    %>
                        <strong>Total revenue for all transactions: <%= String.format("%.2f", totalRevenue) %></strong>
                    <%
                        }
                    %>
                </div>
            <%
                } else {
            %>
                <p class="text-muted">No sales records found.</p>
            <%
                }
            %>
    </div>
</body>
</html>