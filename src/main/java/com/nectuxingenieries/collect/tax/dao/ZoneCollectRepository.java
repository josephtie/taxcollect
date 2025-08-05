package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.ZoneCollecte;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ZoneCollectRepository extends JpaRepository<ZoneCollecte, Long>, JpaSpecificationExecutor<ZoneCollecte> {

    List<ZoneCollecte> findByQuartierId(Long quartierId);
    Page<ZoneCollecte> findByQuartierId(Long quartierId, Pageable pageable);
}

