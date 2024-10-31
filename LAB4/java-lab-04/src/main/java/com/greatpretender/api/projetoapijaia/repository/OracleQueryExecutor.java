package com.greatpretender.api.projetoapijaia.repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class OracleQueryExecutor {

    public long executeHardcodedQuery() throws SQLException {
        String queryTemplate = "SELECT * FROM tabela WHERE COL1 = "; // template para concatenar o valor de COL1

        try (Statement statement = DatabaseConnection.getConnection().createStatement()) {

            long startTime = System.currentTimeMillis();

            // Loop para 5.000 execuções com valores diferentes
            for (int i = 1; i <= 5000; i++) {
                String query = queryTemplate + i; // Monta a query com o valor atual de i
                ResultSet resultSet = statement.executeQuery(query);

                // Processa o resultado
                while (resultSet.next()) {
                    int col1 = resultSet.getInt("COL1");
                    String col2 = resultSet.getString("COL2");
                    System.out.println("Concat (Hardcoded) = COL1: " + col1 + ", COL2: " + col2);
                }
                resultSet.close();
            }

            long endTime = System.currentTimeMillis();
            return endTime - startTime;
        }
    }

    public long executePreparedStatementQuery() throws SQLException {
        String query = "SELECT * FROM tabela WHERE COL1 = ?";

        try (PreparedStatement preparedStatement = DatabaseConnection.getConnection().prepareStatement(query)) {

            long startTime = System.currentTimeMillis();

            // Loop para 5.000 execuções com valores diferentes
            for (int i = 1; i <= 5000; i++) {
                preparedStatement.setInt(1, i); // Define o valor atual de i no parâmetro
                ResultSet resultSet = preparedStatement.executeQuery();

                // Processa o resultado
                while (resultSet.next()) {
                    int col1 = resultSet.getInt("COL1");
                    String col2 = resultSet.getString("COL2");
                    System.out.println("PreparedST (Softcoded) = COL1: " + col1 + ", COL2: " + col2);
                }
                resultSet.close();
            }

            long endTime = System.currentTimeMillis();
            return endTime - startTime;
        }
    }
}
