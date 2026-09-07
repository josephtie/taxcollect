package com.nectuxingenieries.collect.tax.dto;

public class GeoLocationResultDto {
    private Double latitude;
    private Double longitude;
    private CommuneDto commune;
    private ZoneDto zone;
    private QuartierDto quartier;
    private SecteurDto secteur;

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public CommuneDto getCommune() { return commune; }
    public void setCommune(CommuneDto commune) { this.commune = commune; }
    public ZoneDto getZone() { return zone; }
    public void setZone(ZoneDto zone) { this.zone = zone; }
    public QuartierDto getQuartier() { return quartier; }
    public void setQuartier(QuartierDto quartier) { this.quartier = quartier; }
    public SecteurDto getSecteur() { return secteur; }
    public void setSecteur(SecteurDto secteur) { this.secteur = secteur; }
}
