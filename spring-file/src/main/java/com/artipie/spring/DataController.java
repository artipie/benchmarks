/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/spring-file/LICENCE.txt
 */
package com.artipie.spring;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.MalformedURLException;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller which contains basic operations for work with data.
 * @since 0.1
 */
@RestController
public final class DataController {
    /**
     * Data service.
     */
    private final DataService dataservice;

    /**
     * Ctor.
     * @param dataservice Data service
     */
    @Autowired
    public DataController(final DataService dataservice) {
        this.dataservice = dataservice;
    }

    /**
     * Upload binary data by specified key.
     * @param type Type of jmx test
     * @param key Key to data
     * @param request Request with binary data
     * @return Response
     */
    @PutMapping(value = "upload/{type}/{key}", consumes = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<String> uploadData(
        final @PathVariable("type") String type,
        final @PathVariable("key") String key,
        final HttpServletRequest request
    ) {
        ResponseEntity<String> res;
        final String name = String.format("%s.%s", type, key);
        try {
            this.dataservice.save(request.getInputStream(), name);
            res = ResponseEntity.status(HttpStatus.CREATED)
                .body(String.format("Uploaded by key '%s'", name));
        } catch (final UncheckedIOException | IOException exc) {
            res = ResponseEntity.internalServerError()
                .body(String.format("Failed to upload by key '%s'", name));
        }
        return res;
    }

    /**
     * Clean root directory from all data.
     * @return Return OK status if cleaning was successful.
     */
    @GetMapping("clean")
    public ResponseEntity<HttpStatus> cleanRoot() {
        this.dataservice.deleteAll();
        return ResponseEntity.ok().build();
    }

    /**
     * Download data by specfied key.
     * @param key Key to resource
     * @return Resource by specified key
     */
    @GetMapping("/files/{key}")
    public ResponseEntity<Resource> data(final @PathVariable("key") String key) {
        ResponseEntity<Resource> res;
        try {
            final Resource data = this.dataservice.data(key);
            res = ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_OCTET_STREAM_VALUE)
                .body(data);
        } catch (final MalformedURLException | FileNotFoundException exc) {
            res = ResponseEntity.badRequest().build();
        }
        return res;
    }
}
