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
import com.syos.model.ShelfStock;
import com.syos.model.Product;

public class ShelfStockRepository {

	private final ProductRepository productRepository;

	public ShelfStockRepository(ProductRepository productRepository) {
		this.productRepository = productRepository;
	}

	public int getQuantity(String productCode) {
		String sql = "SELECT SUM(quantity_on_shelf) FROM shelf_stock WHERE product_code = ?";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			ResultSet resultSet = preparedStatement.executeQuery();
			if (resultSet.next()) {
				return resultSet.getInt(1);
			}
		} catch (Exception e) {
			throw new RuntimeException("Error getting total shelf quantity for product: " + productCode, e);
		}
		return 0;
	}

	public void upsertBatchQuantityOnShelf(String productCode, int batchId, int quantity, LocalDate expiryDate) {
		String sql = """
				INSERT INTO shelf_stock(product_code, batch_id, quantity_on_shelf, expiry_date)
				VALUES(?, ?, ?, ?)
				ON CONFLICT(product_code, batch_id) DO UPDATE
				  SET quantity_on_shelf = shelf_stock.quantity_on_shelf + EXCLUDED.quantity_on_shelf,
				      expiry_date = EXCLUDED.expiry_date
				""";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			preparedStatement.setInt(2, batchId);
			preparedStatement.setInt(3, quantity);
			preparedStatement.setDate(4, Date.valueOf(expiryDate));
			preparedStatement.executeUpdate();
		} catch (Exception e) {
			throw new RuntimeException("Error upserting batch quantity on shelf for batch ID: " + batchId, e);
		}
	}

	public void deductQuantityFromBatchOnShelf(String productCode, int batchId, int qtyToDeduct) {
		String sql = """
				UPDATE shelf_stock
				SET quantity_on_shelf = quantity_on_shelf - ?
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
					"Error deducting quantity from batch " + batchId + " on shelf for product " + productCode, e);
		}
	}

	public void removeBatchFromShelf(String productCode, int batchId) {
		String sql = "DELETE FROM shelf_stock WHERE product_code = ? AND batch_id = ?";
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
			preparedStatement.setString(1, productCode);
			preparedStatement.setInt(2, batchId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException("Error removing batch " + batchId + " from shelf for product " + productCode, e);
		}
	}

	public List<ShelfStock> getBatchesOnShelf(String productCode) {
		String sql = """
				SELECT ss.product_code, ss.batch_id, ss.quantity_on_shelf, ss.expiry_date
				FROM shelf_stock ss
				WHERE ss.product_code = ? AND ss.quantity_on_shelf > 0
				ORDER BY ss.expiry_date ASC, ss.batch_id ASC
				""";
		List<ShelfStock> shelfBatches = new ArrayList<>();
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

			preparedStatement.setString(1, productCode);
			ResultSet resultSet = preparedStatement.executeQuery();
			while (resultSet.next()) {

				Product product = productRepository.findByCode(resultSet.getString("product_code"));
				if (product == null) {

					System.err.println("Warning: Product " + resultSet.getString("product_code")
							+ " not found for shelf stock batch " + resultSet.getInt("batch_id"));
					continue;
				}

				shelfBatches.add(new ShelfStock(product, resultSet.getInt("quantity_on_shelf"),
						resultSet.getInt("batch_id"), resultSet.getDate("expiry_date").toLocalDate()));
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error loading shelf batches for product: " + productCode, e);
		}
		return shelfBatches;
	}

	public List<String> getAllProductCodes() {
		String sql = "SELECT DISTINCT product_code FROM shelf_stock";
		List<String> productCodes = new ArrayList<>();
		try (Connection connection = DatabaseManager.getInstance().getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(sql);
				ResultSet resultSet = preparedStatement.executeQuery()) {

			while (resultSet.next()) {
				productCodes.add(resultSet.getString("product_code"));
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error getting all product codes from shelf", e);
		}
		return productCodes;
	}

	public ShelfStock findByCode(String productCode) {
		String sql = """
				SELECT ss.product_code, ss.batch_id, ss.quantity_on_shelf, ss.expiry_date
				FROM shelf_stock ss
				WHERE ss.product_code = ? AND ss.quantity_on_shelf > 0
				ORDER BY ss.expiry_date ASC, ss.batch_id ASC
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
							+ " referenced by shelf stock entry (batch " + resultSet.getInt("batch_id")
							+ ") not found in product catalog.");
				}
				return new ShelfStock(product, resultSet.getInt("quantity_on_shelf"), resultSet.getInt("batch_id"),
						resultSet.getDate("expiry_date").toLocalDate());
			}
		} catch (SQLException e) {
			throw new RuntimeException("Error finding single shelf stock entry for product: " + productCode, e);
		}
		return null;
	}
}