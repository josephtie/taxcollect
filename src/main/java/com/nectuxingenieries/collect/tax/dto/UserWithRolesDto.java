package com.nectuxingenieries.collect.tax.dto;

import lombok.Data;
import java.util.List;

@Data
public class UserWithRolesDto {
    private UserRepresentationDTO userdto;
    private List<String> roles;
}
