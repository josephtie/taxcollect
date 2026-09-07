package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.LoginRequest;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
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
@Tag(name = "Authentification", description = "API d'authentification Keycloak")
public class AuthController {

    private final RestTemplateBuilder restTemplateBuilder;

    @Value("${keycloak.admin.host:http://localhost:8080}")
    private String keycloakHost;

    @Value("${keycloak.admin.realm:mairie}")
    private String keycloakRealm;

    @Value("${keycloak.admin.clientId:tax-backend}")
    private String keycloakClientId;

    @Value("${keycloak.admin.clientSecret:}")
    private String keycloakClientSecret;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        String tokenUrl = String.format("%s/realms/%s/protocol/openid-connect/token", keycloakHost, keycloakRealm);

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        
        // Use the clientId from the request, or fall back to the default
        String clientId = loginRequest.getClientId() != null && !loginRequest.getClientId().isBlank() 
            ? loginRequest.getClientId() : keycloakClientId;
        form.add("client_id", clientId);
        
        // Only add client_secret for confidential clients (tax-backend, keycloak-admin-client)
        // tax-frontend is a public client and doesn't need a secret
        if (!"tax-frontend".equals(clientId)) {
            form.add("client_secret", keycloakClientSecret);
        }
        form.add("username", loginRequest.getUsername());
        form.add("password", loginRequest.getPassword());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(form, headers);

        RestTemplate restTemplate = restTemplateBuilder.build();
        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(tokenUrl, entity, Map.class);
            return ResponseEntity.ok(response.getBody());
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
