package com.syos.repository;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.syos.db.DatabaseManager;
import com.syos.model.OnlineStock;
import com.syos.model.Product;

public class OnlineStockRepository {

	private final ProductRepository productRepository;

	public OnlineStockRepository(ProductRepository productRepository) {
		this.productRepository = productRepository;
	}

	public int getQuantity(String productCode) {
		String sql = "SELECT SUM(quantity) FROM online_stock WHERE product_code = ?";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			ResultSet resultSet = preparedStatement.executeQuery();
			if (resultSet.next()) {
				return resultSet.getInt(1);
			}
		} catch (Exception e) {
			throw new RuntimeException("Error getting total online quantity for product: " + productCode, e);
		}
		return 0;
	}

	public void upsertBatchQuantityOnline(String productCode, int batchId, int quantity, LocalDate expiryDate) {
		// First check if exists
		String selectSql = "SELECT quantity FROM online_stock WHERE product_code = ? AND batch_id = ?";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {

			selectStmt.setString(1, productCode);
			selectStmt.setInt(2, batchId);
			ResultSet rs = selectStmt.executeQuery();

			if (rs.next()) {
				// Update existing
				int existingQuantity = rs.getInt("quantity");
				String updateSql = "UPDATE online_stock SET quantity = ?, expiry_date = ? WHERE product_code = ? AND batch_id = ?";
				try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
					updateStmt.setInt(1, existingQuantity + quantity);
					updateStmt.setDate(2, Date.valueOf(expiryDate));
					updateStmt.setString(3, productCode);
					updateStmt.setInt(4, batchId);
					updateStmt.executeUpdate();
				}
			} else {
				// Insert new
				String insertSql = "INSERT INTO online_stock(product_code, batch_id, quantity, expiry_date) VALUES(?, ?, ?, ?)";
				try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
					insertStmt.setString(1, productCode);
					insertStmt.setInt(2, batchId);
					insertStmt.setInt(3, quantity);
					insertStmt.setDate(4, Date.valueOf(expiryDate));
					insertStmt.executeUpdate();
				}
			}
		} catch (Exception e) {
			throw new RuntimeException("Error upserting batch quantity online for batch ID: " + batchId, e);
		}
	}

	public void deductQuantityFromBatchOnline(String productCode, int batchId, int qtyToDeduct) {
		String sql = """
				UPDATE online_stock
				SET quantity = quantity - ?
				WHERE product_code = ? AND batch_id = ?
				""";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setInt(1, qtyToDeduct);
			preparedStatement.setString(2, productCode);
			preparedStatement.setInt(3, batchId);
			preparedStatement.executeUpdate();
		} catch (Exception e) {
			throw new RuntimeException(
					"Error deducting quantity from batch " + batchId + " online for product " + productCode, e);
		}
	}

	public void removeBatchFromOnline(String productCode, int batchId) {
		String sql = "DELETE FROM online_stock WHERE product_code = ? AND batch_id = ?";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
			preparedStatement.setString(1, productCode);
			preparedStatement.setInt(2, batchId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException("Error removing batch " + batchId + " from online for product " + productCode, e);
		}
	}

	public List<OnlineStock> getBatchesOnline(String productCode) {
		String sql = """
				SELECT os.product_code, os.batch_id, os.quantity, os.expiry_date
				FROM online_stock os
				WHERE os.product_code = ? AND os.quantity > 0
				ORDER BY os.expiry_date ASC, os.batch_id ASC
				""";
		List<OnlineStock> onlineBatches = new ArrayList<>();
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			ResultSet resultSet = preparedStatement.executeQuery();
			while (resultSet.next()) {

				Product product = productRepository.findByCode(resultSet.getString("product_code"));
				if (product == null) {

					System.err.println("Warning: Product " + resultSet.getString("product_code")
							+ " not found for online stock batch " + resultSet.getInt("batch_id"));
					continue;
				}

				onlineBatches.add(new OnlineStock(product, resultSet.getInt("quantity"),
						resultSet.getInt("batch_id"), resultSet.getDate("expiry_date").toLocalDate()));
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error loading online batches for product: " + productCode, e);
		}
		return onlineBatches;
	}

	public List<String> getAllProductCodes() {
		String sql = "SELECT DISTINCT product_code FROM online_stock";
		List<String> productCodes = new ArrayList<>();
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql);
				ResultSet resultSet = preparedStatement.executeQuery()) {

			while (resultSet.next()) {
				productCodes.add(resultSet.getString("product_code"));
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error getting all product codes from online", e);
		}
		return productCodes;
	}

	public OnlineStock findByCode(String productCode) {
		String sql = """
				SELECT os.product_code, os.batch_id, os.quantity, os.expiry_date
				FROM online_stock os
				WHERE os.product_code = ? AND os.quantity > 0
				ORDER BY os.expiry_date ASC, os.batch_id ASC
				LIMIT 1
				""";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			ResultSet resultSet = preparedStatement.executeQuery();

			if (resultSet.next()) {
				Product product = productRepository.findByCode(resultSet.getString("product_code"));
				if (product == null) {
					throw new RuntimeException("Data inconsistency: Product " + resultSet.getString("product_code")
							+ " referenced by online stock entry (batch " + resultSet.getInt("batch_id")
							+ ") not found in product catalog.");
				}
				return new OnlineStock(product, resultSet.getInt("quantity"), resultSet.getInt("batch_id"),
						resultSet.getDate("expiry_date").toLocalDate());
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error finding single online stock entry for product: " + productCode, e);
		}
		return null;
	}
}