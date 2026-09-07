package com.nectuxingenieries.collect.tax.jobs;

import com.nectuxingenieries.collect.tax.services.AssessmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
@Log4j2
public class DailyAssessmentJob {

    @Autowired
    private AssessmentService assessmentService;

    @Scheduled(cron = "0 0 1 * * *")
    public void generateDailyAssessments() {
        log.info("=== Démarrage du job quotidien de génération d'avis ===");
        try {
            int generated = assessmentService.generateForAllActiveTaxes(LocalDate.now());
            log.info("=== Job terminé: {} avis générés ===", generated);
        } catch (Exception e) {
            log.error("Erreur lors du job de génération d'avis", e);
        }
    }

    @Scheduled(cron = "0 5 1 * * *")
    public void markOverdueAssessments() {
        log.info("=== Vérification des avis en retard ===");
        try {
            int overdue = assessmentService.markOverdueAssessments();
            log.info("=== {} avis marqués en retard ===", overdue);
        } catch (Exception e) {
            log.error("Erreur lors du marquage des avis en retard", e);
        }
    }
}
