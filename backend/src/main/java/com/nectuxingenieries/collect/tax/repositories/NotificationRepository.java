package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.Notification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface NotificationRepository extends BaseRepository<Notification, Long>, JpaSpecificationExecutor<Notification> {

    @Query("SELECT n FROM Notification n WHERE n.agentId = :agentId AND n.deletedAt IS NULL ORDER BY n.createdAt DESC")
    List<Notification> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT n FROM Notification n WHERE n.agentId = :agentId AND n.lu = false AND n.deletedAt IS NULL ORDER BY n.createdAt DESC")
    List<Notification> findUnreadByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.agentId = :agentId AND n.lu = false AND n.deletedAt IS NULL")
    long countUnreadByAgentId(@Param("agentId") Long agentId);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.lu = true, n.dateLecture = CURRENT_TIMESTAMP WHERE n.id = :id")
    void markAsRead(@Param("id") Long id);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.lu = true, n.dateLecture = CURRENT_TIMESTAMP WHERE n.agentId = :agentId AND n.lu = false")
    void markAllAsRead(@Param("agentId") Long agentId);
}
