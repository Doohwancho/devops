package com.cho.springboot.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class HelloResult {
    private String message;
    private String time;
}
