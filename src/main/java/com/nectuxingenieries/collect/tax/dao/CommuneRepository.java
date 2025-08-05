package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Commune;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommuneRepository extends JpaRepository<Commune, Long>, JpaSpecificationExecutor<Commune> {

    List<Commune> findAllByOrderByNomAsc();
    Page<Commune> findAllByOrderByNomAsc(Pageable pageable);
}
