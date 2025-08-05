package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.TaxeCollect;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaxeCollectRepository extends JpaRepository<TaxeCollect, Long>, JpaSpecificationExecutor<TaxeCollect> {

    List<TaxeCollect> findByZoneId(Long communeId);
    Page<TaxeCollect> findByZoneId(Long communeId, Pageable pageable);
}

