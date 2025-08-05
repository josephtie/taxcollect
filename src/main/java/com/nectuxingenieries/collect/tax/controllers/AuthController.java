package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.models.dto.LoginRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final RestTemplateBuilder restTemplateBuilder;



    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        String tokenUrl = "http://localhost:8080/realms/mairie/protocol/openid-connect/token";

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", "tax-backend");
        form.add("client_secret", "Ztyd4oPVESZVXynuaopgo29EZcYZsAmV");
        form.add("username", request.getUsername());
        form.add("password", request.getPassword());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(form, headers);

        RestTemplate restTemplate = restTemplateBuilder.build();
        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(tokenUrl, entity, Map.class);
            return ResponseEntity.ok(response.getBody()); // contient access_token, refresh_token, etc.
        } catch (HttpClientErrorException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
        }
    }
    @GetMapping("/api/debug/roles")
    public ResponseEntity<?> roles(Authentication auth) {
        return ResponseEntity.ok(auth.getAuthorities());
    }
}
