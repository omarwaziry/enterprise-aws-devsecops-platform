package com.example.devsecops.controller;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class AppController {

    @Value("${app.version:1.0.0}")
    private String appVersion;

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("status", "UP");
        payload.put("service", "devsecops-app");
        payload.put("version", appVersion);
        payload.put("timestamp", Instant.now().toString());
        return payload;
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("status", "READY");
        payload.put("service", "devsecops-app");
        payload.put("timestamp", Instant.now().toString());
        return ResponseEntity.ok(payload);
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("application", "devsecops-app");
        payload.put("version", appVersion);
        payload.put("environment", System.getenv().getOrDefault("SPRING_PROFILES_ACTIVE", "default"));
        return payload;
    }

    @GetMapping("/hello")
    public Map<String, Object> hello(@RequestParam(defaultValue = "world") String name) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("message", "Hello, " + name + "!");
        payload.put("service", "devsecops-app");
        payload.put("timestamp", Instant.now().toString());
        return payload;
    }
}
