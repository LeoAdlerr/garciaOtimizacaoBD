package com.greatpretender.api.projetoapijaia.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL = "jdbc:oracle:thin:@localhost:1521/orclcdb";
    private static final String USERNAME = "system";
    private static final String PASSWORD = "oracle";

    private static Connection connection = null;

    private DatabaseConnection() {
        // Construtor privado para evitar instanciamento
    }

    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        }
        return connection;
    }
}
