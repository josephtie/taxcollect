package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.PaymentChannel;
import jakarta.persistence.*;

@Entity
@Table(name = "payment_provider_config")
public class PaymentProviderConfig extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "provider_code", nullable = false, length = 64)
    private String providerCode;

    @Column(name = "display_name", length = 128)
    private String displayName;

    @Column(name = "commune_id")
    private Long communeId;

    @Enumerated(EnumType.STRING)
    @Column(length = 32)
    private PaymentChannel channel;

    @Column(nullable = false)
    private int priority = 0;

    @Column(nullable = false)
    private boolean enabled = true;

    @Column(nullable = false)
    private boolean sandbox = true;

    @Column(name = "base_url_sandbox", length = 512)
    private String baseUrlSandbox;

    @Column(name = "base_url_prod", length = 512)
    private String baseUrlProd;

    @Column(name = "credentials_ref", length = 255)
    private String credentialsRef;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getProviderCode() { return providerCode; }
    public void setProviderCode(String providerCode) { this.providerCode = providerCode; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public Long getCommuneId() { return communeId; }
    public void setCommuneId(Long communeId) { this.communeId = communeId; }
    public PaymentChannel getChannel() { return channel; }
    public void setChannel(PaymentChannel channel) { this.channel = channel; }
    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public boolean isSandbox() { return sandbox; }
    public void setSandbox(boolean sandbox) { this.sandbox = sandbox; }
    public String getBaseUrlSandbox() { return baseUrlSandbox; }
    public void setBaseUrlSandbox(String baseUrlSandbox) { this.baseUrlSandbox = baseUrlSandbox; }
    public String getBaseUrlProd() { return baseUrlProd; }
    public void setBaseUrlProd(String baseUrlProd) { this.baseUrlProd = baseUrlProd; }
    public String getCredentialsRef() { return credentialsRef; }
    public void setCredentialsRef(String credentialsRef) { this.credentialsRef = credentialsRef; }
}
