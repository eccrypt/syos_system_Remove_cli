package com.syos.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.syos.dto.BillItemReportDTO;
import com.syos.dto.BillReportDTO;
import com.syos.dto.ProductStockReportItemDTO;
import com.syos.dto.ReportDTOMapper;
import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.repository.ProductRepository;
import com.syos.repository.ReportRepository;
import com.syos.repository.ShelfStockRepository;
import com.syos.repository.StockBatchRepository;
import java.util.ArrayList;

@WebServlet("/reports")
public class ReportsServlet extends HttpServlet {
    private final ReportRepository reportRepository;

    public ReportsServlet() {
        ProductRepository productRepository = new ProductRepository();
        ShelfStockRepository shelfStockRepository = new ShelfStockRepository(productRepository);
        StockBatchRepository stockBatchRepository = new StockBatchRepository();
        this.reportRepository = new ReportRepository(productRepository, shelfStockRepository, stockBatchRepository);
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

        List<Bill> bills = reportRepository.getBillsByDate(date);
        List<BillReportDTO> billReportDTOs = generateBillReportDTOs(bills);
        double totalRevenue = billReportDTOs.stream().mapToDouble(BillReportDTO::getTotalAmount).sum();

        request.setAttribute("reportDate", date);
        request.setAttribute("billReportDTOs", billReportDTOs);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/salesReport.jsp").forward(request, response);
    }

    private void handleAllTransactions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Bill> bills = reportRepository.getAllBills();
        List<BillReportDTO> billReportDTOs = generateBillReportDTOs(bills);
        double totalRevenue = billReportDTOs.stream().mapToDouble(BillReportDTO::getTotalAmount).sum();

        request.setAttribute("billReportDTOs", billReportDTOs);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/salesReport.jsp").forward(request, response);
    }

    private void handleProductStock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ProductStockReportItemDTO> reportItems = reportRepository.getProductStockReportData(0);
        request.setAttribute("reportItems", reportItems);
        request.getRequestDispatcher("/productStockReport.jsp").forward(request, response);
    }

    private void handleAnalysis(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Simplified, just show product stock
        handleProductStock(request, response);
    }

    private List<BillReportDTO> generateBillReportDTOs(List<Bill> bills) {
        List<BillReportDTO> billReportDTOs = new ArrayList<>();
        for (Bill bill : bills) {
            List<BillItem> billItems = reportRepository.getBillItemsByBillId(bill.getId());
            List<BillItemReportDTO> itemDTOs = billItems.stream()
                    .map(ReportDTOMapper::toBillItemReportDTO)
                    .collect(java.util.stream.Collectors.toList());
            BillReportDTO billDTO = ReportDTOMapper.toBillReportDTO(bill, itemDTOs);
            billReportDTOs.add(billDTO);
        }
        return billReportDTOs;
    }
}