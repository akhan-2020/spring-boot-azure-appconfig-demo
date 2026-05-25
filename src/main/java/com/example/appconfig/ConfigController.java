package com.example.appconfig;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class ConfigController {
    
    @Value("${app.message:Default Message}")
    private String message;
    
    @Value("${database-password:not-configured}")
    private String databasePassword;
    
    @GetMapping("/")
    public Map<String, String> getConfig() {
        return Map.of(
            "message", message,
            "databasePasswordConfigured", databasePassword.equals("not-configured") ? "false" : "true",
            "source", "Azure App Configuration + Key Vault"
        );
    }
    
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }
}
