/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/spring-file/LICENCE.header
 */
package com.artipie.spring;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import javax.servlet.http.HttpServletRequest;
import org.hamcrest.MatcherAssert;
import org.hamcrest.core.IsEqual;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Tests for {@link DataController}.
 * @since 0.1
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@SuppressWarnings("PMD.AvoidDuplicateLiterals")
public final class DataControllerTest {
    /**
     * Server-side Spring MVC test support.
     */
    private MockMvc mock;

    /**
     * Web context.
     */
    @Autowired
    private WebApplicationContext context;

    /**
     * Controller for working with data.
     */
    @Autowired
    private DataController controller;

    /**
     * Data service.
     */
    @MockBean
    private DataService service;

    @Before
    public void setUp() {
        this.mock = MockMvcBuilders.webAppContextSetup(this.context)
            .alwaysDo(MockMvcResultHandlers.print())
            .build();
    }

    @Test
    public void uploadsBinaryData() throws Exception {
        this.mock.perform(
            MockMvcRequestBuilders.put("/upload/bin")
                .content("some binary data for upload to the server")
                .characterEncoding("UTF-8")
        ).andExpect(MockMvcResultMatchers.status().isCreated());
    }

    @Test
    public void failsWhenUploadFails() throws Exception {
        final HttpServletRequest request = Mockito.mock(HttpServletRequest.class);
        Mockito.when(request.getInputStream()).thenAnswer(
            ignore -> {
                throw new IOException();
            }
        );
        MatcherAssert.assertThat(
            this.controller.uploadData("bin", request).getStatusCode().is5xxServerError(),
            new IsEqual<>(true)
        );
    }

    @Test
    public void getsDataByKey() throws Exception {
        final String body = "got result";
        Mockito.when(this.service.data("bin")).thenReturn(
            new InputStreamResource(
                new ByteArrayInputStream(body.getBytes(StandardCharsets.UTF_8))
            )
        );
        this.mock.perform(
            MockMvcRequestBuilders.get("/files/bin")
        ).andExpect(MockMvcResultMatchers.status().isOk())
        .andExpect(
            MockMvcResultMatchers.content().contentType(MediaType.APPLICATION_OCTET_STREAM_VALUE)
        ).andExpect(MockMvcResultMatchers.content().bytes(body.getBytes(StandardCharsets.UTF_8)));
    }

    @Test
    public void failsGetDataByAbsentKey() throws Exception {
        Mockito.when(this.service.data("bin")).thenAnswer(
            ignore -> {
                throw new FileNotFoundException();
            }
        );
        this.mock.perform(
            MockMvcRequestBuilders.get("/files/bin")
        ).andExpect(MockMvcResultMatchers.status().isBadRequest());
    }
}
