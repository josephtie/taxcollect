package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Contribuable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ContribuableRepository extends JpaRepository<Contribuable, Long>, JpaSpecificationExecutor<Contribuable> {

    List<Contribuable> findByZoneCollecteId(Long quartierId);
    Page<Contribuable> findByZoneCollecteId(Long quartierId, Pageable pageable);




}

