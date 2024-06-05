package com.cho.springboot.service;

import com.cho.springboot.domain.HelloResult;
import com.cho.springboot.repository.TimeRepository;
import org.springframework.stereotype.Service;

@Service
public class HelloWorldService {

    private final TimeRepository timeRepository;

    public HelloWorldService(TimeRepository timeRepository) {
        this.timeRepository = timeRepository;
    }

    public HelloResult getInfo() {
        String date = timeRepository.getFormattedTime();
        return new HelloResult("hello world!", date);
    }

}