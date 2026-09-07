package com.nectuxingenieries.collect.tax.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/taxcollect/upload")
@CrossOrigin(origins = {"http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:5173"}, allowedHeaders = "*", allowCredentials = "true")
public class FileUploadController {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${server.port:9091}")
    private String serverPort;

    @PostMapping("/agent-photo")
    public ResponseEntity<?> uploadAgentPhoto(@RequestParam("file") MultipartFile file) {
        return handleImageUpload(file, "agents", "agent_");
    }

    @PostMapping("/contribuable-photo")
    public ResponseEntity<?> uploadContribuablePhoto(@RequestParam("file") MultipartFile file) {
        return handleImageUpload(file, "contribuables", "contribuable_");
    }

    @PostMapping("/piece-identite")
    public ResponseEntity<?> uploadPieceIdentite(@RequestParam("file") MultipartFile file) {
        return handleImageUpload(file, "pieces", "piece_");
    }

    private ResponseEntity<?> handleImageUpload(MultipartFile file, String subDir, String prefix) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Fichier vide"));
        }

        try {
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Le fichier doit être une image"));
            }

            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            String filename = prefix + UUID.randomUUID() + extension;
            Path uploadPath = Paths.get(uploadDir, subDir);
            Files.createDirectories(uploadPath);

            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath);

            String fileUrl = "/uploads/" + subDir + "/" + filename;

            return ResponseEntity.ok(Map.of("url", fileUrl));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "Erreur lors de l'upload: " + e.getMessage()));
        }
    }
}
