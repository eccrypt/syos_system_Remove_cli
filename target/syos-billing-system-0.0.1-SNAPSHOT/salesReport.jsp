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
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .bill-section { margin: 20px 0; border: 1px solid #ccc; padding: 10px; }
        .total { font-weight: bold; font-size: 1.2em; }
        .back-link { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="back-link">
        <a href="reports.jsp">← Back to Reports Menu</a>
    </div>

    <h1>Sales Report</h1>

    <%
        LocalDate reportDate = (LocalDate) request.getAttribute("reportDate");
        List<BillReportDTO> billReportDTOs = (List<BillReportDTO>) request.getAttribute("billReportDTOs");
        Double totalRevenue = (Double) request.getAttribute("totalRevenue");

        if (reportDate != null) {
    %>
        <h2>Report for: <%= reportDate.format(DateTimeFormatter.ISO_DATE) %></h2>
    <%
        } else {
    %>
        <h2>All Transactions Report</h2>
    <%
        }

        if (billReportDTOs != null && !billReportDTOs.isEmpty()) {
            for (BillReportDTO billDTO : billReportDTOs) {
    %>
                <div class="bill-section">
                    <h3>Bill #<%= billDTO.getSerialNumber() %> - Date: <%= billDTO.getBillDate().toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate().format(DateTimeFormatter.ISO_DATE) %> - Type: <%= billDTO.getTransactionType() %></h3>
                    <p><strong>Cash Tendered:</strong> <%= String.format("%.2f", billDTO.getCashTendered()) %> | <strong>Change Returned:</strong> <%= String.format("%.2f", billDTO.getChangeReturned()) %></p>

                    <%
                        List<BillItemReportDTO> itemDTOs = billDTO.getItems();
                        if (itemDTOs != null && !itemDTOs.isEmpty()) {
                    %>
                        <table>
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
                        <p class="total">Total for Bill #<%= billDTO.getSerialNumber() %>: <%= String.format("%.2f", billDTO.getTotalAmount()) %></p>
                    <%
                        } else {
                    %>
                        <p>No items found for this bill.</p>
                    <%
                        }
                    %>
                </div>
            <%
                }
            %>

            <div class="total">
                <%
                    if (reportDate != null) {
                %>
                    Total revenue for <%= reportDate.format(DateTimeFormatter.ISO_DATE) %>: <%= String.format("%.2f", totalRevenue) %>
                <%
                    } else {
                %>
                    Total revenue for all transactions: <%= String.format("%.2f", totalRevenue) %>
                <%
                    }
                %>
            </div>
        <%
            } else {
        %>
            <p>No sales records found.</p>
        <%
            }
        %>
</body>
</html>