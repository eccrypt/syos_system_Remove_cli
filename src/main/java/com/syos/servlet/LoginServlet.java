package com.syos.servlet;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.syos.model.User;
import com.syos.service.AuthenticationService;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final AuthenticationService authService = new AuthenticationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("index.jsp");
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = authService.authenticate(email, password);
            if (user != null) {
                // Create session
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getId().toString());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("userRole", user.getRole().toString());
                session.setAttribute("userName", getUserName(user));

                response.sendRedirect("index.jsp");
            } else {
                request.setAttribute("error", "Invalid email or password");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private String getUserName(User user) {
        if (user instanceof com.syos.model.Admin) {
            return ((com.syos.model.Admin) user).getName();
        } else if (user instanceof com.syos.model.Staff) {
            return ((com.syos.model.Staff) user).getName();
        }
        return user.getEmail();
    }
}