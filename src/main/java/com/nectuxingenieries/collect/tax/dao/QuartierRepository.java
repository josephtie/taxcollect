package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Quartier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuartierRepository extends JpaRepository<Quartier, Long>, JpaSpecificationExecutor<Quartier> {

    List<Quartier> findByCommuneId(Long communeId);
    Page<Quartier> findByCommuneId(Long communeId, Pageable pageable);
}
