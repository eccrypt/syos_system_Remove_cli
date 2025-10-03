package com.syos.servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.model.Product;
import com.syos.repository.ProductRepository;

@WebServlet("/onlineStore")
public class OnlineStoreServlet extends HttpServlet {
    private final ProductRepository productRepository = new ProductRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> products = productRepository.findAll();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/onlineStore.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        Product product = productRepository.findByCode(code);
        request.setAttribute("searchedProduct", product);
        doGet(request, response);
    }
}