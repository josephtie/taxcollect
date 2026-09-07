package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.exceptions.NotFoundException;
import com.nectuxingenieries.collect.tax.models.*;
import com.nectuxingenieries.collect.tax.models.enums.*;
import com.nectuxingenieries.collect.tax.payment.PaymentProvider;
import com.nectuxingenieries.collect.tax.payment.PaymentProviderFactory;
import com.nectuxingenieries.collect.tax.payment.dto.*;
import com.nectuxingenieries.collect.tax.repositories.*;
import com.nectuxingenieries.collect.tax.utils.ReceiptNumberGenerator;
import com.nectuxingenieries.collect.tax.utils.TransactionHashUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@Transactional
public class PaymentService {

    @Autowired private PaymentProviderFactory paymentProviderFactory;
    @Autowired private CollectionOrderRepository collectionOrderRepository;
    @Autowired private PaymentAttemptRepository paymentAttemptRepository;
    @Autowired private TaxeCollectRepository taxeCollectRepository;
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private ReceiptRepository receiptRepository;
    @Autowired private PaymentStateMachine paymentStateMachine;

    public CollectionOrder createCollectionOrder(Long taxeCollectId, PaymentChannel channel) {
        TaxeCollect taxeCollect = taxeCollectRepository.findById(taxeCollectId)
                .orElseThrow(() -> new NotFoundException("TaxeCollect", taxeCollectId));

        CollectionOrder order = new CollectionOrder();
        order.setReference("CO-" + (taxeCollect.getReference() != null ? taxeCollect.getReference() : "TC-" + taxeCollectId) + "-01");
        order.setTaxeCollectId(taxeCollectId);
        order.setContribuableId(taxeCollect.getContribuable().getId());
        order.setAmount(taxeCollect.getRemainingAmount() != null ? taxeCollect.getRemainingAmount() : taxeCollect.getMontant());
        order.setCurrency(taxeCollect.getCurrency() != null ? taxeCollect.getCurrency() : "XOF");
        order.setChannel(channel);
        order.setStatus(CollectionOrderStatus.OPEN);
        order.setExpiresAt(LocalDateTime.now().plusHours(24));
        return collectionOrderRepository.save(order);
    }

    public PaymentInitiationResponse initiatePayment(Long collectionOrderId, String paymentMethod, String idempotencyKey) {
        CollectionOrder order = collectionOrderRepository.findById(collectionOrderId)
                .orElseThrow(() -> new NotFoundException("CollectionOrder", collectionOrderId));

        if (order.getStatus() != CollectionOrderStatus.OPEN && order.getStatus() != CollectionOrderStatus.PENDING_PAYMENT) {
            throw new IllegalStateException("CollectionOrder n'est plus disponible pour paiement: " + order.getStatus());
        }

        TaxeCollect taxeCollect = taxeCollectRepository.findById(order.getTaxeCollectId())
                .orElseThrow(() -> new NotFoundException("TaxeCollect", order.getTaxeCollectId()));

        PaymentInitiationRequest request = new PaymentInitiationRequest();
        request.setCollectionOrderReference(order.getReference());
        request.setTaxReference(taxeCollect.getReference());
        request.setTaxpayerId(order.getContribuableId());
        request.setAmount(order.getAmount());
        request.setCurrency(order.getCurrency());
        request.setPaymentMethod(paymentMethod);
        request.setIdempotencyKey(idempotencyKey);
        request.setChannel(order.getChannel().name());

        PaymentProvider provider = paymentProviderFactory.resolve(request);
        PaymentInitiationResponse response = provider.initiatePayment(request);

        // Créer PaymentAttempt
        int attemptNumber = paymentAttemptRepository.findByCollectionOrderId(collectionOrderId).size() + 1;
        PaymentAttempt attempt = new PaymentAttempt();
        attempt.setCollectionOrderId(collectionOrderId);
        attempt.setAttemptNumber(attemptNumber);
        attempt.setProvider(provider.getProviderCode());
        attempt.setProviderTransactionId(response.getProviderTransactionId());
        attempt.setAmount(order.getAmount());
        attempt.setStatus(StatutTransaction.INITIATED);
        paymentAttemptRepository.save(attempt);

        // Mettre à jour le statut de la CollectionOrder
        order.setStatus(CollectionOrderStatus.PENDING_PAYMENT);
        collectionOrderRepository.save(order);

        return response;
    }

    @Transactional
    public Transaction confirmPayment(String providerTransactionId, String providerCode, String status, BigDecimal amount, String failureReason) {
        PaymentAttempt attempt = paymentAttemptRepository.findAll().stream()
                .filter(a -> providerTransactionId.equals(a.getProviderTransactionId()))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("PaymentAttempt", providerTransactionId));

        CollectionOrder order = collectionOrderRepository.findById(attempt.getCollectionOrderId())
                .orElseThrow(() -> new NotFoundException("CollectionOrder", attempt.getCollectionOrderId()));

        TaxeCollect taxeCollect = taxeCollectRepository.findById(order.getTaxeCollectId())
                .orElseThrow(() -> new NotFoundException("TaxeCollect", order.getTaxeCollectId()));

        StatutTransaction newStatus = mapProviderStatus(status);
        paymentStateMachine.validateTransition(attempt.getStatus(), newStatus);
        attempt.setStatus(newStatus);
        attempt.setFailureReason(failureReason);
        paymentAttemptRepository.save(attempt);

        if (newStatus == StatutTransaction.SUCCESS) {
            // Créer la Transaction
            Transaction transaction = new Transaction();
            transaction.setMontant(amount != null ? amount : order.getAmount());
            transaction.setContribuable(taxeCollect.getContribuable());
            transaction.setZone(taxeCollect.getZone());
            transaction.setModePaiement(ModePaiement.DIRECT_PAYMENT);
            transaction.setStatut(StatutTransaction.SUCCESS);
            transaction.setNumeroRecu(ReceiptNumberGenerator.generateReceiptNumber());
            transaction.setTransactionReference("PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            transaction.setProvider(providerCode);
            transaction.setProviderTransactionId(providerTransactionId);
            transaction.setCurrency(order.getCurrency());
            transaction.setPaymentMethod(attempt.getProvider());
            transaction.setInitiatedAt(LocalDateTime.now());
            transaction.setCompletedAt(LocalDateTime.now());
            transaction.setIdempotencyKey(attempt.getProvider() + "-" + providerTransactionId);
            transaction.setCollectionOrderId(order.getId());
            transaction.setTaxeCollect(taxeCollect);
            transaction.setOffline(false);
            transaction.setDateCreation(LocalDateTime.now());

            String hash = TransactionHashUtil.generateTransactionHash(
                    null, transaction.getMontant(),
                    taxeCollect.getContribuable().getId(),
                    null, transaction.getDateCreation());
            transaction.setHashTransaction(hash);

            Transaction saved = transactionRepository.save(transaction);

            // Mettre à jour le hash avec l'ID réel
            saved.setHashTransaction(TransactionHashUtil.generateTransactionHash(
                    saved.getId(), saved.getMontant(),
                    saved.getContribuable().getId(),
                    null, saved.getDateCreation()));
            saved = transactionRepository.save(saved);

            // Mettre à jour TaxeCollect
            taxeCollect.setPaye(true);
            taxeCollect.setStatut(StatutPayment.PAYE);
            taxeCollect.setDatePaiement(LocalDateTime.now().toLocalDate());
            taxeCollect.setModePaiement(ModePaiement.DIRECT_PAYMENT);
            taxeCollect.setNumeroRecu(saved.getNumeroRecu());
            taxeCollectRepository.save(taxeCollect);

            // Mettre à jour CollectionOrder
            order.setStatus(CollectionOrderStatus.PAID);
            collectionOrderRepository.save(order);

            // Générer le Receipt
            Receipt receipt = new Receipt();
            receipt.setReceiptNumber(saved.getNumeroRecu());
            receipt.setTransactionId(saved.getId());
            receipt.setTaxeCollectId(taxeCollect.getId());
            receipt.setTaxpayerId(order.getContribuableId());
            receipt.setAmount(saved.getMontant());
            receipt.setCurrency(order.getCurrency());
            receipt.setProvider(providerCode);
            receipt.setProviderTransactionId(providerTransactionId);
            receipt.setIssuedAt(LocalDateTime.now());
            receiptRepository.save(receipt);

            return saved;
        }

        return null;
    }

    public PaymentStatusResponse getPaymentStatus(String providerTransactionId) {
        PaymentAttempt attempt = paymentAttemptRepository.findAll().stream()
                .filter(a -> providerTransactionId.equals(a.getProviderTransactionId()))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("PaymentAttempt", providerTransactionId));

        PaymentStatusResponse response = new PaymentStatusResponse();
        response.setProviderTransactionId(providerTransactionId);
        response.setStatus(attempt.getStatus().name());
        response.setFailureReason(attempt.getFailureReason());
        return response;
    }

    private StatutTransaction mapProviderStatus(String status) {
        if (status == null) return StatutTransaction.PENDING;
        return switch (status.toUpperCase()) {
            case "SUCCESS", "SUCCESSFUL", "COMPLETED" -> StatutTransaction.SUCCESS;
            case "FAILED", "DECLINED", "ERROR" -> StatutTransaction.FAILED;
            case "PENDING", "PROCESSING" -> StatutTransaction.PENDING;
            case "EXPIRED", "TIMEOUT" -> StatutTransaction.EXPIRED;
            case "CANCELLED", "CANCELED" -> StatutTransaction.ANNULEE;
            default -> StatutTransaction.PENDING;
        };
    }
}
