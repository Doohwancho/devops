package com.cho.springboot.service;


import com.cho.springboot.domain.Country;
import com.cho.springboot.repository.CountryRepository;
import io.micrometer.core.instrument.MeterRegistry;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class CountryService {

    private final CountryRepository countryRepository;
    private final MeterRegistry meterRegistry;

    public CountryService(CountryRepository countryRepository, MeterRegistry meterRegistry) {
        this.countryRepository = countryRepository;
        this.meterRegistry = meterRegistry;
    }

    public List<Country> getAllCountries() {
        meterRegistry.counter("service.getAllCountries").increment();
        return countryRepository.getAll();
    }

    public Country getCountryByCode(String countryCode) {
        return countryRepository.getCountryByCode(countryCode);
    }
}