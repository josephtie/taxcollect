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
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**","/auth/login","/auth/api/debug/roles").permitAll()
                        .requestMatchers("/api/hello/admin").hasRole("ADMIN")
                        .requestMatchers("/api/hello/user").hasAnyRole("USER", "ADMIN")
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthConverter)))
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }
}
//
//import lombok.RequiredArgsConstructor;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
//import org.springframework.security.config.http.SessionCreationPolicy;
//import org.springframework.security.web.SecurityFilterChain;
//
//@RequiredArgsConstructor
//@Configuration
//@EnableWebSecurity
//public class WebSecurityConfig {
//
//   @Autowired
//   private  JwtAuthConverter jwtAuthConverter;
//
//    private static final String[] SWAGGER_WHITELIST = {
//            "/v3/api-docs/**",
//            "/swagger-ui/**",
//            "/swagger-ui.html"
//    };
//
//
//
//
//
//    @Bean
//    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
//
//        http
//            .authorizeHttpRequests(authz -> authz
//                    .requestMatchers(SWAGGER_WHITELIST).permitAll()
//                    //.requestMatchers("/api/v1/rapports/fichiers/**").permitAll()
//                    //.requestMatchers("/api/v1/rapports/**").permitAll()
//                    .anyRequest().authenticated()
//            )
//            .csrf(AbstractHttpConfigurer::disable)
//            .oauth2ResourceServer(oauth2 -> oauth2
//                    .jwt(jwt -> jwt
//                            .jwtAuthenticationConverter(jwtAuthConverter)
//                    )
//            )
//            .sessionManagement(session -> session
//                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
//            );
//
//        return http.build();
//
//    }
//
//}