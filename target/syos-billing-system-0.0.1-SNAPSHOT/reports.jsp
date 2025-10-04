<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Report Menu</title>
</head>
<body>
    <h1>Report Menu</h1>
    <a href="index.jsp">Back to Main Menu</a>

    <h2>Daily Sales Report</h2>
    <form action="reports" method="post">
        <input type="hidden" name="action" value="dailySales">
        <label>Date (YYYY-MM-DD): <input type="date" name="date"></label>
        <input type="submit" value="Generate">
    </form>

    <h2>All Transactions Report</h2>
    <form action="reports" method="post">
        <input type="hidden" name="action" value="allTransactions">
        <input type="submit" value="Generate">
    </form>

    <h2>Product Stock Report</h2>
    <form action="reports" method="post">
        <input type="hidden" name="action" value="productStock">
        <input type="submit" value="Generate">
    </form>

    <h2>Shelf & Inventory Analysis</h2>
    <form action="reports" method="post">
        <input type="hidden" name="action" value="analysis">
        <input type="submit" value="Generate">
    </form>
</body>
</html>