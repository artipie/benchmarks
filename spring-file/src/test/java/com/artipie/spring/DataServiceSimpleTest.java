/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/spring-file/LICENCE.txt
 */
package com.artipie.spring;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.hamcrest.MatcherAssert;
import org.hamcrest.core.IsEqual;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

/**
 * Test for {@link DataService.Simple}.
 * @since 0.1
 */
@SuppressWarnings("PMD.AvoidDuplicateLiterals")
final class DataServiceSimpleTest {
    /**
     * Temp directory.
     * @checkstyle VisibilityModifierCheck (5 lines)
     */
    @TempDir
    Path tmp;

    @Test
    void savesDataByKey() throws IOException {
        final String key = "key";
        final String data = "some data";
        final DataService service = new DataService.Simple(this.tmp);
        service.save(new ByteArrayInputStream(data.getBytes(StandardCharsets.UTF_8)), key);
        MatcherAssert.assertThat(
            Files.readAllLines(this.tmp.resolve(key)).get(0),
            new IsEqual<>(data)
        );
    }

    @Test
    void readsDataByKey() throws IOException {
        final String key = "key";
        final String data = "some data";
        Files.write(this.tmp.resolve(key), data.getBytes(StandardCharsets.UTF_8));
        final DataService service = new DataService.Simple(this.tmp);
        MatcherAssert.assertThat(
            Files.readAllLines(service.data(key).getFile().toPath()).get(0),
            new IsEqual<>(data)
        );
    }

    @Test
    void failsToReadByAbsentKey() {
        final DataService service = new DataService.Simple(this.tmp);
        Assertions.assertThrows(
            FileNotFoundException.class,
            () -> service.data("absent").getFile()
        );
    }

    @Test
    void cleansRootDirectory() throws IOException {
        final String key = "key";
        final String data = "some data";
        Files.write(this.tmp.resolve(key), data.getBytes(StandardCharsets.UTF_8));
        final DataService service = new DataService.Simple(this.tmp);
        service.deleteAll();
        MatcherAssert.assertThat(
            this.tmp.resolve(key).toFile().exists(),
            new IsEqual<>(false)
        );
    }
}
