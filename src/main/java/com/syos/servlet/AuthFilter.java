package com.syos.servlet;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.syos.enums.UserType;
import com.syos.model.User;
import com.syos.service.AuthenticationService;

@WebFilter("/*")
public class AuthFilter implements Filter {
    private AuthenticationService authService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.authService = new AuthenticationService();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        if (path.equals("/login") || path.equals("/login.jsp") ||
            path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") ||
            path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".gif")) {
            chain.doFilter(request, response);
            return;
        }
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }
        try {
            String userId = (String) session.getAttribute("userId");
            User dbUser = authService.findUserById(userId);
            if (dbUser == null) {
                session.invalidate();
                httpResponse.sendRedirect(contextPath + "/login");
                return;
            }
            session.setAttribute("user", dbUser);
            session.setAttribute("userRole", dbUser.getRole().toString());

        } catch (SQLException e) {
            System.err.println("Database error during auth validation: " + e.getMessage());
        }
        UserType userRole = UserType.valueOf((String) session.getAttribute("userRole"));
        if (!hasAccess(userRole, path)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Insufficient privileges.");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean hasAccess(UserType userRole, String path) {
        if (userRole == UserType.ADMIN) {
            return true;
        }
        if (userRole == UserType.STAFF) {
            return path.startsWith("/billing") ||
                   path.startsWith("/inventory") ||
                   path.equals("/") ||
                   path.equals("/index.jsp") ||
                   path.startsWith("/logout");
        }

        return false;
    }

    @Override
    public void destroy() {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'destroy'");
    }

}