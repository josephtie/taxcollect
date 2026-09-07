package com.nectuxingenieries.collect.tax.payment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class IdempotencyService {

    private final StringRedisTemplate redisTemplate;

    @Autowired
    public IdempotencyService(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public boolean checkAndStore(String key, Duration ttl) {
        Boolean stored = redisTemplate.opsForValue().setIfAbsent("idempotency:" + key, "1", ttl);
        return Boolean.TRUE.equals(stored);
    }

    public boolean isProcessed(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey("idempotency:" + key));
    }

    public void storeResult(String key, String result, Duration ttl) {
        redisTemplate.opsForValue().set("idempotency:" + key, result, ttl);
    }

    public String getResult(String key) {
        return redisTemplate.opsForValue().get("idempotency:" + key);
    }
}
