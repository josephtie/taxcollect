package com.nectuxingenieries.collect.tax;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = "com.nectuxingenieries.collect.tax")
@EntityScan(basePackages = "com.nectuxingenieries.collect.tax.models")

@EnableJpaRepositories(basePackages = "com.nectuxingenieries.collect.tax.repositories")
@EnableScheduling
public class TaxApplication {
	public static void main(String[] args) {
		SpringApplication.run(TaxApplication.class, args);
	}

}
