package com.syos.Controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.dto.CustomerRegisterRequestDTO;
import com.syos.enums.UserType;
import com.syos.service.CustomerRegistrationService;

@WebServlet("/customerRegister")
public class CustomerRegisterServlet extends HttpServlet {
    private final CustomerRegistrationService registrationService = new CustomerRegistrationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/customerRegister.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("/customerRegister.jsp").forward(request, response);
            return;
        }

        CustomerRegisterRequestDTO requestDTO = new CustomerRegisterRequestDTO(
            firstName, lastName, email, password, UserType.CUSTOMER);

        try {
            registrationService.register(requestDTO);
            request.setAttribute("success", "Registration successful! Please login.");
            request.getRequestDispatcher("/customerLogin.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/customerRegister.jsp").forward(request, response);
        }
    }
}