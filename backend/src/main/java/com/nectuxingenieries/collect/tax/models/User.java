package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "users")
@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User extends Auditable {
    @Id
    private String id; // correspond à l'UUID Keycloak

    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phone;
    private boolean active;


}
