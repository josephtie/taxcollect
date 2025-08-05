package com.nectuxingenieries.collect.tax.models.dto;

import lombok.Data;

@Data
public class UserRepresentationDTO {
    private String id;
    private String username;
    private String email;
    private boolean enabled;
}
