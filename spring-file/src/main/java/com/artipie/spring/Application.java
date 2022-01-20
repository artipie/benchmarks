/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/spring-file/LICENCE.txt
 */
package com.artipie.spring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point of application.
 * @since 0.1
 * @checkstyle HideUtilityClassConstructorCheck (500 lines)
 */
@SpringBootApplication
@SuppressWarnings({"PMD.UseUtilityClass", "PMD.ProhibitPublicStaticMethods"})
public class Application {
    /**
     * Entry point of application.
     * @param args Application args
     */
    public static void main(final String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
