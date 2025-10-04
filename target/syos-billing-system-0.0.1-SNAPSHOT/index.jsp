<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>SYOS Billing System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        .header {
            background-color: #4CAF50;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .menu-container {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .menu-item {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 20px;
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .menu-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .menu-item h3 {
            margin-top: 0;
            color: #333;
        }
        .menu-item p {
            color: #666;
            margin-bottom: 15px;
        }
        .menu-item a {
            display: inline-block;
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 3px;
            transition: background-color 0.2s;
        }
        .menu-item a:hover {
            background-color: #0056b3;
        }
        .logout-btn {
            background-color: #dc3545;
            color: white;
            padding: 8px 16px;
            text-decoration: none;
            border-radius: 3px;
            font-size: 14px;
        }
        .logout-btn:hover {
            background-color: #c82333;
        }
        .user-info {
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>SYOS Billing System</h1>
            <div class="user-info">
                Welcome, <%= session.getAttribute("userName") %> (<%= session.getAttribute("userRole") %>)
            </div>
        </div>
        <a href="logout" class="logout-btn">Logout</a>
    </div>

    <div class="menu-container">
        <h2>Main Menu</h2>

        <div class="menu-grid">
            <%
                String userRole = (String) session.getAttribute("userRole");
                boolean isAdmin = "ADMIN".equals(userRole);
                boolean isStaff = "STAFF".equals(userRole);
            %>

            <% if (isAdmin || isStaff) { %>
            <div class="menu-item">
                <h3>Store Billing</h3>
                <p>Process customer transactions and manage bills</p>
                <a href="billing">Access Billing</a>
            </div>
            <% } %>

            <% if (isAdmin) { %>
            <div class="menu-item">
                <h3>Online Store</h3>
                <p>Manage online store operations</p>
                <a href="onlineStore">Access Online Store</a>
            </div>
            <% } %>

            <% if (isAdmin || isStaff) { %>
            <div class="menu-item">
                <h3>Inventory Management</h3>
                <p>Manage products, stock, and shelf operations</p>
                <a href="inventory">Access Inventory</a>
            </div>
            <% } %>

            <% if (isAdmin) { %>
            <div class="menu-item">
                <h3>Reports</h3>
                <p>Generate sales and inventory reports</p>
                <a href="reports">Access Reports</a>
            </div>
            <% } %>
        </div>

        <% if (!isAdmin && !isStaff) { %>
        <div style="text-align: center; margin-top: 40px; color: #666;">
            <p>You don't have access to any modules. Please contact your administrator.</p>
        </div>
        <% } %>
    </div>
</body>
</html>