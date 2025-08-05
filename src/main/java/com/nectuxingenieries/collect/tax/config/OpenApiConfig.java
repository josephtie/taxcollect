package com.nectuxingenieries.collect.tax.config;


import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI springShopOpenAPI() {
        return new OpenAPI()
                .info(new Info().title("TaxCollect API")
                        .description("Digitalisation des Taxes Communales")
                        .version("v0.0.1")
                        .license(new License().name("Apache 2.0").url("http://localhost")))
                        .externalDocs(new ExternalDocumentation()
                        .description("TaxCollect Wiki Documentation"));
                        //.url("https://springshop.wiki.github.org/docs"));
    }


}
