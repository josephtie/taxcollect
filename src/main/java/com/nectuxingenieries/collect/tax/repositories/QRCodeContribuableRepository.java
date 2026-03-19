package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.QRCodeContribuable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface QRCodeContribuableRepository extends JpaRepository<QRCodeContribuable, Long> {

    Optional<QRCodeContribuable> findByCodeQR(String codeQR);

    List<QRCodeContribuable> findByContribuableId(Long contribuableId);

    List<QRCodeContribuable> findByActifTrue();

    @Query("SELECT qr FROM QRCodeContribuable qr WHERE qr.contribuable.id = :contribuableId AND qr.actif = true ORDER BY qr.dateGeneration DESC")
    List<QRCodeContribuable> findActiveQRCodeByContribuable(@Param("contribuableId") Long contribuableId);

    @Query("SELECT qr FROM QRCodeContribuable qr WHERE qr.dateExpiration < :now AND qr.actif = true")
    List<QRCodeContribuable> findExpiredQRCode(@Param("now") LocalDateTime now);

    boolean existsByCodeQR(String codeQR);

    @Query("SELECT COUNT(qr) FROM QRCodeContribuable qr WHERE qr.contribuable.id = :contribuableId AND qr.actif = true")
    Long countActiveQRCodeByContribuable(@Param("contribuableId") Long contribuableId);
}
