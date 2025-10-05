<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Registration - SYOS System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="bg-white d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h1 class="text-center mb-4">Customer Registration</h1>

                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger" role="alert">
                                <%= request.getAttribute("error") %>
                            </div>
                        <% } %>

                        <form action="customerRegister" method="post">
                            <div class="mb-3">
                                <label for="firstName" class="form-label">First Name:</label>
                                <input type="text" id="firstName" name="firstName" class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label for="lastName" class="form-label">Last Name:</label>
                                <input type="text" id="lastName" name="lastName" class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label">Email:</label>
                                <input type="email" id="email" name="email" class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Password:</label>
                                <input type="password" id="password" name="password" class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label for="confirmPassword" class="form-label">Confirm Password:</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required>
                            </div>

                            <button type="submit" class="btn btn-primary w-100">Register</button>
                        </form>

                        <div class="text-center mt-3">
                            <p>Already have an account? <a href="customerLogin.jsp">Login here</a></p>
                            <p><a href="login.jsp">Admin/Staff Login</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>