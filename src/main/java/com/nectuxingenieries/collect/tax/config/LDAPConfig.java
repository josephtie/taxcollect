package com.nectuxingenieries.collect.tax.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.*;

import org.springframework.ldap.core.LdapTemplate;
import org.springframework.ldap.core.support.LdapContextSource;

@Configuration
@PropertySource("classpath:application.properties")
@ComponentScan(basePackages = {"com.nectuxingenieries.collect.tax.*"})
//@Profile("dev")

public class LDAPConfig {

    @Value("${spring.ldap.urls}")
    private String ldapServer;

    @Value("${spring.ldap.base}")
    private String ldapUserDn;

    @Value("${spring.ldap.password}")
    private String ldapUserPassword;

    @Bean
    public LdapTemplate getLdapTemplate() {
        LdapContextSource contextSource = new LdapContextSource();
        contextSource.setUrl(ldapServer);
        contextSource.setUserDn(ldapUserDn);
        contextSource.setPassword(ldapUserPassword);
        try {
            contextSource.afterPropertiesSet();
        }
        catch(Exception e) {
            e.printStackTrace();
        }
        LdapTemplate ldapTemplate = new LdapTemplate();
        ldapTemplate.setContextSource(contextSource);
        return ldapTemplate;
    }
}