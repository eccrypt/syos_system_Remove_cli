package com.syos.model;

import com.syos.enums.UserType;

public class Admin extends User {
    private final String name;

    public Admin(String email, String password, String name) {
        super(email, password);
        this.name = name;
    }

    public String getName() {
        return name;
    }

    @Override
    public UserType getRole() {
        return UserType.ADMIN;
    }
}