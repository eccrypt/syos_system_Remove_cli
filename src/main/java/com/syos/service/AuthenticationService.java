package com.syos.service;

import java.sql.SQLException;

import com.syos.enums.UserType;
import com.syos.model.User;
import com.syos.repository.UserRepository;
import org.mindrot.jbcrypt.BCrypt;

public class AuthenticationService {
    private final UserRepository userRepository;

    public AuthenticationService() {
        this.userRepository = new UserRepository();
    }

    public User authenticate(String email, String password) throws SQLException {
        User user = userRepository.findByEmail(email);
        if (user != null) {
            boolean passwordMatches;
            if (user.getRole() == UserType.CUSTOMER) {
                // Customers have hashed passwords
                passwordMatches = BCrypt.checkpw(password, user.getPassword());
            } else {
                // Admin and Staff have plain passwords (assuming for now)
                passwordMatches = password.equals(user.getPassword());
            }
            if (passwordMatches) {
                return user;
            }
        }
        return null;
    }

    public User findUserById(String id) throws SQLException {
        return userRepository.findById(id);
    }

    public void registerUser(User user, String plainPassword) throws SQLException {
        User userWithPassword = createUserWithPassword(user, plainPassword);
        userRepository.save(userWithPassword, plainPassword);
    }

    private User createUserWithPassword(User originalUser, String password) {
        if (originalUser instanceof com.syos.model.Admin) {
            com.syos.model.Admin admin = (com.syos.model.Admin) originalUser;
            return new com.syos.model.Admin(admin.getEmail(), password, admin.getName());
        } else if (originalUser instanceof com.syos.model.Staff) {
            com.syos.model.Staff staff = (com.syos.model.Staff) originalUser;
            return new com.syos.model.Staff(staff.getEmail(), password, staff.getName());
        }
        throw new IllegalArgumentException("Unsupported user type");
    }
}