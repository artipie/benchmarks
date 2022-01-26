/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/artipie-file/LICENCE.txt
 */
package com.artipie.file;

import com.artipie.http.Response;
import com.artipie.http.Slice;
import com.artipie.http.async.AsyncResponse;
import com.artipie.http.rs.RsStatus;
import com.artipie.http.rs.RsWithStatus;
import com.artipie.http.rs.StandardRs;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import org.apache.commons.io.FileUtils;
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
        return new AsyncResponse(
            CompletableFuture.runAsync(
                () -> {
                    try {
                        FileUtils.deleteDirectory(this.toclean.toFile());
                    } catch (final IOException exc) {
                        throw new UncheckedIOException(exc);
                    }
                }
            ).handle(
                (res, thr) -> {
                    final Response resp;
                    if (thr == null) {
                        resp = StandardRs.OK;
                    } else {
                        resp = new RsWithStatus(RsStatus.INTERNAL_ERROR);
                    }
                    return resp;
                }
            )
        );
    }
}
