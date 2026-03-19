package com.nectuxingenieries.collect.tax.dto;

import java.util.List;
import java.util.UUID;



public class UserDto {
    private UUID id;
    private String username;
    private String email;
    private String fullName;
    private boolean activated;
    private List<String> roles;
}
