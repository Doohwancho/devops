package com.ensat.healthcheck;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.health.CompositeHealthContributor;
import org.springframework.boot.actuate.health.HealthContributor;
import org.springframework.boot.actuate.health.NamedContributor;
import org.springframework.stereotype.Component;

/**
 * @author Pratik Das
 *
 * 기능
 * 1. the URL shortener service is reachable(미구현. 그냥 localhost:8080에 접속 되는지만 확인), and
 * 2. we can run SQL queries on the USERS table used in the API.
 *
 * 결과값은 아래와 같음.
 * "HealthcareManager": {
 *    "status": "UP",
 *    "components": {
 *       "데이터베이스": {
 *          "status": "UP"
 *       },
 *       "임의의서비스": {
 *          "status": "OUT_OF_SERVICE", //에러난 경우
 *          "details": {
 *             "error": "..."
 *          }
 *       }
 *    }
 * },
 * ...
 * }
 */
@Component("HealthcareManager")
public class HealthcareManager implements CompositeHealthContributor {
    private Map<String, HealthContributor> contributors = new LinkedHashMap<>();

    @Autowired
    public HealthcareManager(
            임의의서비스HealthIndicator notYetMadeServiceHealthContributor,
            DatabaseHealthContributor databaseHealthContributor) {
        super();

        // 미구현 - Health Indicator of URL shortener service
        contributors.put("임의의서비스", notYetMadeServiceHealthContributor);

        //Health Indicator of Database
        contributors.put("데이터베이스", databaseHealthContributor);
    }

    /**
     *  return list of health contributors
     */
    @Override
    public Iterator<NamedContributor<HealthContributor>>
    iterator() {
        return contributors.entrySet().stream()
                .map((entry) ->
                        NamedContributor.of(entry.getKey(),
                                entry.getValue())).iterator();
    }

    @Override
    public HealthContributor getContributor(String name) {
        return contributors.get(name);
    }

}


