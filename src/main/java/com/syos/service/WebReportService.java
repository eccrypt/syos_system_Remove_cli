package com.syos.service;

import java.time.LocalDate;
import java.util.List;

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

public class WebReportService {
    private final ReportRepository reportRepository;

    public WebReportService() {
        ProductRepository productRepository = new ProductRepository();
        ShelfStockRepository shelfStockRepository = new ShelfStockRepository(productRepository);
        StockBatchRepository stockBatchRepository = new StockBatchRepository();
        this.reportRepository = new ReportRepository(productRepository, shelfStockRepository, stockBatchRepository);
    }

    public List<BillReportDTO> getDailySalesReport(LocalDate date) {
        List<Bill> bills = reportRepository.getBillsByDate(date);
        return generateBillReportDTOs(bills);
    }

    public List<BillReportDTO> getAllTransactionsReport() {
        List<Bill> bills = reportRepository.getAllBills();
        return generateBillReportDTOs(bills);
    }

    public List<ProductStockReportItemDTO> getProductStockReport() {
        return reportRepository.getProductStockReportData(0);
    }

    private List<BillReportDTO> generateBillReportDTOs(List<Bill> bills) {
        return bills.stream()
            .map(bill -> {
                List<BillItem> billItems = reportRepository.getBillItemsByBillId(bill.getId());
                List<BillItemReportDTO> itemDTOs = billItems.stream()
                    .map(ReportDTOMapper::toBillItemReportDTO)
                    .toList();
                return ReportDTOMapper.toBillReportDTO(bill, itemDTOs);
            })
            .toList();
    }

    public double getTotalRevenue(List<BillReportDTO> billReportDTOs) {
        return billReportDTOs.stream().mapToDouble(BillReportDTO::getTotalAmount).sum();
    }
}