package com.nectuxingenieries.collect.tax.config;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Paths;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private static final Logger log = LoggerFactory.getLogger(WebMvcConfig.class);

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @PostConstruct
    public void init() {
        String absolutePath = Paths.get(uploadDir).toAbsolutePath().toString();
        log.info("Upload directory resolved to: {}", absolutePath);
        if (!Files.exists(Paths.get(uploadDir))) {
            log.warn("Upload directory does not exist! Creating it...");
            try {
                Files.createDirectories(Paths.get(uploadDir));
            } catch (Exception e) {
                log.error("Failed to create upload directory: {}", e.getMessage());
            }
        }
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absolutePath = Paths.get(uploadDir).toAbsolutePath().toString();
        log.info("Registering resource handler /uploads/** -> file:{}/", absolutePath);
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + absolutePath + "/")
                .setCachePeriod(3600);
    }
}
