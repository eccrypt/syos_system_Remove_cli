package com.syos.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.syos.db.DatabaseManager;
import com.syos.model.Bill;
import com.syos.model.BillItem;
import com.syos.model.Product;

public class BillingRepository {

	public void save(Bill bill) {
		String insertBill = """
				INSERT INTO bill
				  (serial_number, bill_date, total_amount, cash_tendered, change_returned, transaction_type)
				VALUES (?, ?, ?, ?, ?, ?)
				RETURNING id
				""";

		String insertItem = """
				INSERT INTO bill_item (bill_id, product_code, quantity, total_price, discount_amount)
				VALUES (?, ?, ?, ?, ?)
				""";

		try (Connection connection = DatabaseManager.getInstance().getConnection()) {
			connection.setAutoCommit(false);

			int generatedBillId;
			try (PreparedStatement preparedStatement = connection.prepareStatement(insertBill)) {
				preparedStatement.setInt(1, bill.getSerialNumber());
				preparedStatement.setTimestamp(2, new Timestamp(bill.getBillDate().getTime()));
				preparedStatement.setDouble(3, bill.getTotalAmount());
				preparedStatement.setDouble(4, bill.getCashTendered());
				preparedStatement.setDouble(5, bill.getChangeReturned());
				preparedStatement.setString(6, bill.getTransactionType());

				ResultSet rs = preparedStatement.executeQuery();
				if (!rs.next()) {
					throw new RuntimeException("Failed to retrieve generated bill ID.");
				}
				generatedBillId = rs.getInt(1);

				bill.setId(generatedBillId);
			}

			try (PreparedStatement preparedStatement = connection.prepareStatement(insertItem)) {
				for (BillItem item : bill.getItems()) {
					preparedStatement.setInt(1, generatedBillId);
					preparedStatement.setString(2, item.getProduct().getCode());
					preparedStatement.setInt(3, item.getQuantity());
					preparedStatement.setDouble(4, item.getTotalPrice());
					preparedStatement.setDouble(5, item.getDiscountAmount());
					preparedStatement.addBatch();
				}
				preparedStatement.executeBatch();
			}

			connection.commit();
		} catch (SQLException e) {
			throw new RuntimeException("Error saving bill & items", e);
		}
	}

	public Bill findById(int billId) {
		String sql = """
				SELECT b.id, b.serial_number, b.bill_date, b.total_amount, b.cash_tendered, b.change_returned, b.transaction_type,
				       bi.id as item_id, bi.quantity, bi.total_price, bi.discount_amount,
				       p.code as product_code, p.name as product_name, p.price as product_price
				  FROM bill b
				  JOIN bill_item bi ON b.id = bi.bill_id
				  JOIN product p ON bi.product_code = p.code
				 WHERE b.id = ?
				 ORDER BY bi.id
				""";

		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setInt(1, billId);
			ResultSet resultSet = preparedStatement.executeQuery();

			Bill bill = null;
			List<BillItem> items = new ArrayList<>();

			while (resultSet.next()) {
				if (bill == null) {
					int serialNumber = resultSet.getInt("serial_number");
					java.util.Date billDate = new java.util.Date(resultSet.getTimestamp("bill_date").getTime());
					double totalAmount = resultSet.getDouble("total_amount");
					double cashTendered = resultSet.getDouble("cash_tendered");
					double changeReturned = resultSet.getDouble("change_returned");
					String transactionType = resultSet.getString("transaction_type");

					bill = new Bill(billId, serialNumber, billDate, totalAmount, cashTendered, changeReturned, transactionType);
				}

				String productCode = resultSet.getString("product_code");
				String productName = resultSet.getString("product_name");
				double productPrice = resultSet.getDouble("product_price");
				Product product = new Product(productCode, productName, productPrice);

				int itemId = resultSet.getInt("item_id");
				int quantity = resultSet.getInt("quantity");
				double totalPrice = resultSet.getDouble("total_price");
				double discountAmount = resultSet.getDouble("discount_amount");

				BillItem item = new BillItem(itemId, billId, product, quantity, totalPrice, discountAmount);
				items.add(item);
			}

			if (bill != null) {
				bill.setItems(items);
			}

			return bill;
		} catch (SQLException e) {
			throw new RuntimeException("Error retrieving bill by ID", e);
		}
	}

	public int nextSerial() {
		String sql = """
				SELECT COALESCE(MAX(serial_number), 0) + 1
				  FROM bill
				 WHERE DATE(bill_date) = CURRENT_DATE
				""";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql);
				ResultSet result = preparedStatement.executeQuery()) {
			if (result.next()) {
				return result.getInt(1);
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error generating daily serial", e);
		}
		return 1;
	}
}
