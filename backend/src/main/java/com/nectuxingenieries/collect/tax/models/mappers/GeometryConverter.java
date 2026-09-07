package com.nectuxingenieries.collect.tax.models.mappers;

import org.locationtech.jts.geom.MultiPolygon;
import org.locationtech.jts.geom.Polygon;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.geom.Coordinate;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

public class GeometryConverter {

    public static final GeometryFactory GEOMETRY_FACTORY = new GeometryFactory(new PrecisionModel(), 4326);
    public static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    public static String multiPolygonToGeoJson(MultiPolygon multiPolygon) {
        if (multiPolygon == null) return null;
        try {
            ObjectNode root = OBJECT_MAPPER.createObjectNode();
            root.put("type", "MultiPolygon");
            ArrayNode coordinates = OBJECT_MAPPER.createArrayNode();
            for (int p = 0; p < multiPolygon.getNumGeometries(); p++) {
                Polygon polygon = (Polygon) multiPolygon.getGeometryN(p);
                ArrayNode rings = OBJECT_MAPPER.createArrayNode();
                // Exterior ring
                ArrayNode exterior = OBJECT_MAPPER.createArrayNode();
                for (Coordinate coord : polygon.getExteriorRing().getCoordinates()) {
                    ArrayNode point = OBJECT_MAPPER.createArrayNode();
                    point.add(coord.x);
                    point.add(coord.y);
                    exterior.add(point);
                }
                rings.add(exterior);
                // Interior rings (holes)
                for (int r = 0; r < polygon.getNumInteriorRing(); r++) {
                    ArrayNode interior = OBJECT_MAPPER.createArrayNode();
                    for (Coordinate coord : polygon.getInteriorRingN(r).getCoordinates()) {
                        ArrayNode point = OBJECT_MAPPER.createArrayNode();
                        point.add(coord.x);
                        point.add(coord.y);
                        interior.add(point);
                    }
                    rings.add(interior);
                }
                coordinates.add(rings);
            }
            root.set("coordinates", coordinates);
            return OBJECT_MAPPER.writeValueAsString(root);
        } catch (Exception e) {
            return null;
        }
    }

    public static MultiPolygon geoJsonToMultiPolygon(String geoJson) {
        if (geoJson == null || geoJson.isBlank()) return null;
        try {
            JsonNode root = OBJECT_MAPPER.readTree(geoJson);
            String type = root.get("type").asText();
            JsonNode coordinates = root.get("coordinates");
            if (coordinates == null || !coordinates.isArray() || coordinates.isEmpty()) return null;

            java.util.List<Polygon> polygons = new java.util.ArrayList<>();

            if ("Polygon".equals(type)) {
                // Single polygon wrapped into MultiPolygon
                polygons.add(parsePolygonRings(coordinates));
            } else if ("MultiPolygon".equals(type)) {
                for (JsonNode polyNode : coordinates) {
                    polygons.add(parsePolygonRings(polyNode));
                }
            }

            if (polygons.isEmpty()) return null;
            return GEOMETRY_FACTORY.createMultiPolygon(polygons.toArray(new Polygon[0]));
        } catch (Exception e) {
            return null;
        }
    }

    private static Polygon parsePolygonRings(JsonNode ringsNode) {
        if (ringsNode == null || !ringsNode.isArray() || ringsNode.isEmpty()) return null;
        // First ring = exterior, rest = holes
        JsonNode exteriorNode = ringsNode.get(0);
        Coordinate[] exteriorCoords = parseRing(exteriorNode);
        org.locationtech.jts.geom.LinearRing[] holes = new org.locationtech.jts.geom.LinearRing[ringsNode.size() - 1];
        for (int i = 1; i < ringsNode.size(); i++) {
            Coordinate[] holeCoords = parseRing(ringsNode.get(i));
            holes[i - 1] = GEOMETRY_FACTORY.createLinearRing(holeCoords);
        }
        org.locationtech.jts.geom.LinearRing exterior = GEOMETRY_FACTORY.createLinearRing(exteriorCoords);
        return GEOMETRY_FACTORY.createPolygon(exterior, holes);
    }

    private static Coordinate[] parseRing(JsonNode ringNode) {
        Coordinate[] coords = new Coordinate[ringNode.size()];
        for (int i = 0; i < ringNode.size(); i++) {
            JsonNode point = ringNode.get(i);
            coords[i] = new Coordinate(point.get(0).asDouble(), point.get(1).asDouble());
        }
        return coords;
    }
}
