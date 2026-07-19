package com.example.devsecops.exception;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<Map<String, Object>> handleTypeMismatch(MethodArgumentTypeMismatchException exception) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("status", HttpStatus.BAD_REQUEST.value());
        payload.put("error", "Bad Request");
        payload.put("message", "The request parameter '" + exception.getName() + "' is invalid.");
        payload.put("timestamp", Instant.now().toString());
        return ResponseEntity.badRequest().body(payload);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneric(Exception exception) {
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        payload.put("error", "Internal Server Error");
        payload.put("message", "An unexpected error occurred.");
        payload.put("timestamp", Instant.now().toString());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(payload);
    }
}
