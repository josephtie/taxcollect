package com.nectuxingenieries.collect.tax.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@EnableMethodSecurity(prePostEnabled = true)
@EnableConfigurationProperties(JwtAuthConverterProperties.class)
public class WebSecurityConfig {

    private final JwtAuthConverter jwtAuthConverter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**","/auth/login","/actuator/health","/actuator/info").permitAll()
                        .requestMatchers("/uploads/**").permitAll()
                        .requestMatchers("/api/payments/webhooks/**").permitAll()
                        .requestMatchers("/api/hello/admin").hasRole("ADMIN")
                        .requestMatchers("/api/hello/user").hasAnyRole("USER", "ADMIN")
                        .requestMatchers("/api/transactions/**").hasAnyRole("ADMIN", "TRESOR", "AGENT")
                        .requestMatchers("/api/cloture-caisse/**").hasAnyRole("ADMIN", "TRESOR", "AGENT")
                        .requestMatchers("/api/recensement/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR")
                        .requestMatchers("/api/taxcollect/agent/**").hasAnyRole("ADMIN", "SUPERVISEUR", "TRESOR", "AGENT")
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthConverter)))
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of(
            "http://localhost:*",     // Autoriser tous les ports localhost
            "http://127.0.0.1:*"    // Autoriser tous les ports 127.0.0.1
        ));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}