package com.nectuxingenieries.collect.tax.dao;

import com.nectuxingenieries.collect.tax.models.Agents;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AgentsRepository extends JpaRepository<Agents, Long>, JpaSpecificationExecutor<Agents> {

//    List<Agents> findByZones(Long zoneId);
//    Page<Agents> findByZones(Long zoneId, Pageable pageable);
}

