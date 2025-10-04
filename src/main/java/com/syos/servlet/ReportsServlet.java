package com.syos.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.dto.BillReportDTO;
import com.syos.dto.ProductStockReportItemDTO;
import com.syos.service.WebReportService;

@WebServlet("/reports")
public class ReportsServlet extends HttpServlet {
    private final WebReportService reportService;

    public ReportsServlet() {
        this.reportService = new WebReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("dailySales".equals(action)) {
            handleDailySales(request, response);
        } else if ("allTransactions".equals(action)) {
            handleAllTransactions(request, response);
        } else if ("productStock".equals(action)) {
            handleProductStock(request, response);
        } else if ("analysis".equals(action)) {
            handleAnalysis(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void handleDailySales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String dateStr = request.getParameter("date");
        LocalDate date = dateStr.isEmpty() ? LocalDate.now() : LocalDate.parse(dateStr);

        List<BillReportDTO> billReportDTOs = reportService.getDailySalesReport(date);
        double totalRevenue = reportService.getTotalRevenue(billReportDTOs);

        request.setAttribute("reportDate", date);
        request.setAttribute("billReportDTOs", billReportDTOs);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/salesReport.jsp").forward(request, response);
    }

    private void handleAllTransactions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<BillReportDTO> billReportDTOs = reportService.getAllTransactionsReport();
        double totalRevenue = reportService.getTotalRevenue(billReportDTOs);

        request.setAttribute("billReportDTOs", billReportDTOs);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/salesReport.jsp").forward(request, response);
    }

    private void handleProductStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ProductStockReportItemDTO> reportItems = reportService.getProductStockReport();
        request.setAttribute("reportItems", reportItems);
        request.getRequestDispatcher("/productStockReport.jsp").forward(request, response);
    }

    private void handleAnalysis(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Simplified, just show product stock
        handleProductStock(request, response);
    }
}