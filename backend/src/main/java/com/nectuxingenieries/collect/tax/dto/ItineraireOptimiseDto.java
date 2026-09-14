package com.nectuxingenieries.collect.tax.dto;

import java.util.List;

public class ItineraireOptimiseDto {
    private Long tourneeId;
    private String pointDepart;
    private List<EtapeItineraire> etapes;
    private double distanceTotaleKm;
    private int dureeEstimeeMinutes;

    public Long getTourneeId() { return tourneeId; }
    public void setTourneeId(Long tourneeId) { this.tourneeId = tourneeId; }
    public String getPointDepart() { return pointDepart; }
    public void setPointDepart(String pointDepart) { this.pointDepart = pointDepart; }
    public List<EtapeItineraire> getEtapes() { return etapes; }
    public void setEtapes(List<EtapeItineraire> etapes) { this.etapes = etapes; }
    public double getDistanceTotaleKm() { return distanceTotaleKm; }
    public void setDistanceTotaleKm(double distanceTotaleKm) { this.distanceTotaleKm = distanceTotaleKm; }
    public int getDureeEstimeeMinutes() { return dureeEstimeeMinutes; }
    public void setDureeEstimeeMinutes(int dureeEstimeeMinutes) { this.dureeEstimeeMinutes = dureeEstimeeMinutes; }

    public static class EtapeItineraire {
        private int ordre;
        private Long contribuableId;
        private String nom;
        private String adresse;
        private Double latitude;
        private Double longitude;
        private double distanceDepuisPrecedentKm;

        public int getOrdre() { return ordre; }
        public void setOrdre(int ordre) { this.ordre = ordre; }
        public Long getContribuableId() { return contribuableId; }
        public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getAdresse() { return adresse; }
        public void setAdresse(String adresse) { this.adresse = adresse; }
        public Double getLatitude() { return latitude; }
        public void setLatitude(Double latitude) { this.latitude = latitude; }
        public Double getLongitude() { return longitude; }
        public void setLongitude(Double longitude) { this.longitude = longitude; }
        public double getDistanceDepuisPrecedentKm() { return distanceDepuisPrecedentKm; }
        public void setDistanceDepuisPrecedentKm(double distanceDepuisPrecedentKm) { this.distanceDepuisPrecedentKm = distanceDepuisPrecedentKm; }
    }
}
