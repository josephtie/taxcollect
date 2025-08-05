package com.nectuxingenieries.collect.tax.models.dto;



import lombok.Data;

@Data
public class ResetPasswordRequest {
    private String newPassword;
    private String matricule;  // ou DN selon ton implémentation

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }
}
