/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/artipie-file/LICENCE.txt
 */
package com.artipie.file;

import com.artipie.http.Response;
import com.artipie.http.Slice;
import com.artipie.http.rs.RsStatus;
import com.artipie.http.rs.RsWithStatus;
import com.artipie.http.rs.StandardRs;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.Map;
import org.reactivestreams.Publisher;

/**
 * Slice for cleaning specified directory.
 * @since 0.1
 */
final class CleanSlice implements Slice {
    /**
     * Path to clean.
     */
    private final Path toclean;

    /**
     * Ctor.
     * @param toclean Path for cleaning
     */
    CleanSlice(final Path toclean) {
        this.toclean = toclean;
    }

    @Override
    public Response response(
        final String line,
        final Iterable<Map.Entry<String, String>> headers,
        final Publisher<ByteBuffer> body
    ) {
        Response res;
        try {
            Files.walk(this.toclean)
                .sorted(Comparator.reverseOrder())
                .map(Path::toFile)
                .forEach(File::delete);
            res = StandardRs.OK;
        } catch (final IOException exc) {
            res = new RsWithStatus(RsStatus.INTERNAL_ERROR);
        }
        return res;
    }
}
