package com.nectuxingenieries.collect.tax;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.nectuxingenieries.collect.tax")
@EntityScan(basePackages = "com.nectuxingenieries.collect.tax.models")
@EnableJpaRepositories(basePackages = "com.nectuxingenieries.collect.tax.repositories")
public class TaxApplication {

	public static void main(String[] args) {
		SpringApplication.run(TaxApplication.class, args);
	}

}
