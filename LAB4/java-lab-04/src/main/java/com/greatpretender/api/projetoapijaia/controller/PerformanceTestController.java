package com.greatpretender.api.projetoapijaia.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import com.greatpretender.api.projetoapijaia.repository.OracleQueryExecutor;

@RestController
@RequestMapping("/test-performance")
public class PerformanceTestController {

    private final OracleQueryExecutor executor;

    public PerformanceTestController() {
        this.executor = new OracleQueryExecutor();
    }

    @GetMapping
    public Map<String, Long> testPerformance() {

        System.out.println("entrou");
        Map<String, Long> result = new HashMap<>();

        try {
            // Executa a query hardcoded e armazena o tempo de execução
            long hardcodedTime = executor.executeHardcodedQuery();
            result.put("hardcodedQueryTime", hardcodedTime);

            // Executa a query com prepared statement e armazena o tempo de execução
            long preparedStatementTime = executor.executePreparedStatementQuery();
            result.put("preparedStatementQueryTime", preparedStatementTime);

        } catch (SQLException e) {
            e.printStackTrace();
            result.put("error", -1L); // Indica erro
        }

        return result;
    }
}
