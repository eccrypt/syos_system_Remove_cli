package com.syos.model;

import com.syos.enums.UserType;

public class Staff extends User {
    private final String name;

    public Staff(String email, String password, String name) {
        super(email, password);
        this.name = name;
    }

    public String getName() {
        return name;
    }

    @Override
    public UserType getRole() {
        return UserType.STAFF;
    }
}