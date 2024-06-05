package com.ensat.healthcheck;

import java.net.Socket;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthContributor;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

/**
 * @author Pratik Das
 *
 */
@Component
@Slf4j
public class 임의의서비스HealthIndicator implements HealthIndicator, HealthContributor {

    private static final String URL = "http://192.168.45.10:8080/";

    @Override
    public Health health() {
        // check if url shortener service url is reachable
        try (Socket socket = new Socket(new java.net.URL(URL).getHost(),8080)) {
        } catch (Exception e1) {
            log.warn("Failed to connect to : {}",URL);
            return Health.down().withDetail("error", e1.getMessage()).build();
        }
        return Health.up().build();
    }
}