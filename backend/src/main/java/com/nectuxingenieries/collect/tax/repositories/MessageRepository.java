package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Message;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends BaseRepository<Message, Long>, JpaSpecificationExecutor<Message> {

    @Query("SELECT m FROM Message m WHERE (m.expediteurId = :userId OR m.destinataireId = :userId) AND m.deletedAt IS NULL ORDER BY m.createdAt ASC")
    List<Message> findConversation(@Param("userId") Long userId);

    @Query("SELECT m FROM Message m WHERE m.signalementId = :signalementId AND m.deletedAt IS NULL ORDER BY m.createdAt ASC")
    List<Message> findBySignalementId(@Param("signalementId") Long signalementId);

    @Query("SELECT m FROM Message m WHERE m.destinataireId = :userId AND m.lu = false AND m.deletedAt IS NULL")
    List<Message> findUnreadByDestinataire(@Param("userId") Long userId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.destinataireId = :userId AND m.lu = false AND m.deletedAt IS NULL")
    long countUnreadByDestinataire(@Param("userId") Long userId);
}
