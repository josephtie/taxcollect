package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Visite;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VisiteRepository extends BaseRepository<Visite, Long>, JpaSpecificationExecutor<Visite> {

    @Query("SELECT v FROM Visite v WHERE v.tournee.id = :tourneeId AND v.deletedAt IS NULL ORDER BY v.ordrePassage")
    List<Visite> findByTourneeId(@Param("tourneeId") Long tourneeId);

    @Query("SELECT v FROM Visite v WHERE v.contribuable.id = :contribuableId AND v.deletedAt IS NULL ORDER BY v.dateVisite DESC")
    List<Visite> findByContribuableId(@Param("contribuableId") Long contribuableId);

    @Query("SELECT v FROM Visite v WHERE v.syncStatus = :syncStatus AND v.deletedAt IS NULL")
    List<Visite> findBySyncStatus(@Param("syncStatus") String syncStatus);
}
