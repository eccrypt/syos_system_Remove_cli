package com.syos.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.syos.db.DatabaseManager;
import com.syos.enums.UserType;
import com.syos.model.Admin;
import com.syos.model.Staff;
import com.syos.model.User;

public class UserRepository {

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT id, email, first_name, last_name, user_type, password FROM users WHERE email = ?";
        try (Connection connection = DatabaseManager.getInstance().getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, email.toLowerCase());
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    String id = resultSet.getString("id");
                    String userEmail = resultSet.getString("email");
                    String firstName = resultSet.getString("first_name");
                    String lastName = resultSet.getString("last_name");
                    String password = resultSet.getString("password");
                    String userTypeStr = resultSet.getString("user_type");

                    UserType role = UserType.valueOf(userTypeStr.toUpperCase());
                    return createUserFromData(id, userEmail, password, firstName + " " + lastName, role);
                }
            }
        }
        return null;
    }

    public User findById(String id) throws SQLException {
        String sql = "SELECT id, email, first_name, last_name, user_type, password FROM users WHERE id = ?";
        try (Connection connection = DatabaseManager.getInstance().getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, id);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    String userId = resultSet.getString("id");
                    String email = resultSet.getString("email");
                    String firstName = resultSet.getString("first_name");
                    String lastName = resultSet.getString("last_name");
                    String password = resultSet.getString("password");
                    String userTypeStr = resultSet.getString("user_type");

                    UserType role = UserType.valueOf(userTypeStr.toUpperCase());
                    return createUserFromData(userId, email, password, firstName + " " + lastName, role);
                }
            }
        }
        return null;
    }

    private User createUserFromData(String id, String email, String password, String name, UserType role) {
        switch (role) {
            case ADMIN:
                return new Admin(email, password, name);
            case STAFF:
                return new Staff(email, password, name);
            default:
                throw new IllegalArgumentException("Unsupported user role: " + role);
        }
    }

    public void save(User user, String plainPassword) throws SQLException {
        String sql = "INSERT INTO users (id, email, first_name, last_name, user_type, password) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseManager.getInstance().getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            String[] nameParts = getUserName(user).split(" ", 2);
            String firstName = nameParts[0];
            String lastName = nameParts.length > 1 ? nameParts[1] : "";

            preparedStatement.setString(1, user.getId().toString());
            preparedStatement.setString(2, user.getEmail());
            preparedStatement.setString(3, firstName);
            preparedStatement.setString(4, lastName);
            preparedStatement.setString(5, user.getRole().toString());
            preparedStatement.setString(6, user.getPassword()); 

            preparedStatement.executeUpdate();
        }
    }

    private String getUserName(User user) {
        if (user instanceof Admin) {
            return ((Admin) user).getName();
        } else if (user instanceof Staff) {
            return ((Staff) user).getName();
        }
        return "";
    }
}