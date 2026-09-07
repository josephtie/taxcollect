package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.TaxeCollectDto;

import java.time.LocalDate;
import java.util.List;

public interface AssessmentService {

    int generateForPeriod(Long taxeId, LocalDate targetDate);

    int generateForAllActiveTaxes(LocalDate targetDate);

    int markOverdueAssessments();

    List<TaxeCollectDto> findAssessmentsByPeriod(LocalDate periodStart, LocalDate periodEnd);

    byte[] exportAssessments(String format, LocalDate periodStart, LocalDate periodEnd);
}
