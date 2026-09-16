package com.nectuxingenieries.collect.tax.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
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
    private final TerritorialScopeFilter territorialScopeFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .addFilterAfter(territorialScopeFilter, UsernamePasswordAuthenticationFilter.class)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**","/auth/login","/auth/refresh","/auth/logout","/actuator/health","/actuator/info").permitAll()
                        .requestMatchers("/uploads/**").permitAll()
                        .requestMatchers("/api/uploads/**").permitAll()
                        .requestMatchers("/api/payments/webhooks/**").permitAll()
                        .requestMatchers("/api/transactions/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR")
                        .requestMatchers("/api/cloture-caisse/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR")
                        .requestMatchers("/api/recensement/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR", "RESPONSABLE_QUARTIER")
                        .requestMatchers("/api/taxcollect/agent/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER", "TRESOR", "AGENT")
                        .requestMatchers("/api/taxcollect/zone/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER")
                        .requestMatchers("/api/taxcollect/quartier/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER")
                        .requestMatchers("/api/taxcollect/secteur/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER")
                        .requestMatchers("/api/taxcollect/commune/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER", "TRESOR", "AGENT")
                        .requestMatchers("/api/taxcollect/contribuable/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER", "TRESOR", "AGENT")
                        .requestMatchers("/api/taxcollect/supervision/**").hasAnyRole("ADMIN", "SUPERVISEUR")
                        .requestMatchers("/api/payments/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR")
                        .requestMatchers("/api/receipts/**").hasAnyRole("ADMIN", "TRESOR", "AGENT")
                        .requestMatchers("/api/reconciliation/**").hasAnyRole("ADMIN", "TRESOR")
                        .requestMatchers("/api/users/**").hasRole("ADMIN")
                        .requestMatchers("/api/assessments/**").hasAnyRole("ADMIN", "TRESOR", "SUPERVISEUR")
                        .requestMatchers("/api/collection-orders/**").hasAnyRole("ADMIN", "TRESOR", "AGENT", "SUPERVISEUR")
                        .requestMatchers("/api/taxcollect/affectation/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER", "AGENT")
                        .requestMatchers("/api/taxcollect/geo/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/collect/**").hasAnyRole("ADMIN", "TRESOR", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/tournee/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/visite/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/portefeuille/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/promesse/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT", "TRESOR")
                        .requestMatchers("/api/taxcollect/notification/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/signalement/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/audit/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT", "RESPONSABLE_QUARTIER")
                        .requestMatchers("/api/taxcollect/caisse/**").hasAnyRole("ADMIN", "SUPERVISEUR", "TRESOR", "AGENT")
                        .requestMatchers("/api/taxcollect/remise-caisse/**").hasAnyRole("ADMIN", "SUPERVISEUR", "TRESOR", "AGENT")
                        .requestMatchers("/api/taxcollect/sync/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/messagerie/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/agent-advanced/**").hasAnyRole("ADMIN", "SUPERVISEUR", "AGENT")
                        .requestMatchers("/api/taxcollect/responsable/**").hasAnyRole("ADMIN", "SUPERVISEUR", "RESPONSABLE_QUARTIER")
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
            "http://localhost:*",
            "http://127.0.0.1:*",
            "http://83.171.249.150:*",
            "https://83.171.249.150:*"
        ));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}