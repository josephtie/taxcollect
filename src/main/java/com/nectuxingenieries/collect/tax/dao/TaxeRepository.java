package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Taxe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaxeRepository extends JpaRepository<Taxe, Long>, JpaSpecificationExecutor<Taxe> {

    List<Taxe> findByPeriodicite(String comm);
    Page<Taxe> findByCategorie(String communeId, Pageable pageable);
}

