package com.syos.factory;

import com.syos.dto.CustomerRegisterRequestDTO;
import com.syos.enums.UserType;
import com.syos.model.Admin;
import com.syos.model.Customer;
import com.syos.model.Staff;
import com.syos.model.User;

public class UserFactory {
	public static User createUser(CustomerRegisterRequestDTO customerRegisterRequestDTO) {
		UserType type = customerRegisterRequestDTO.getUserType();
		switch (type) {
		case CUSTOMER:
			return new Customer.CustomerBuilder().firstName(customerRegisterRequestDTO.getFirstName())
					.lastName(customerRegisterRequestDTO.getLastName()).email(customerRegisterRequestDTO.getEmail())
					.password(customerRegisterRequestDTO.getPassword()).build();
		default:
			throw new IllegalArgumentException("Unsupported user type: " + type);
		}
	}

	public static User createUser(String email, String password, String name, UserType role) {
		switch (role) {
		case ADMIN:
			return new Admin(email, password, name);
		case STAFF:
			return new Staff(email, password, name);
		default:
			throw new IllegalArgumentException("Unsupported user type: " + role);
		}
	}
}
