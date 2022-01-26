/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/artipie-file/LICENCE.txt
 */
package com.artipie.file;

import com.artipie.vertx.VertxSliceServer;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Entry point of Artipie application.
 * @since 0.1
 * @checkstyle HideUtilityClassConstructorCheck (500 lines)
 */
@SuppressWarnings({"PMD.UseUtilityClass", "PMD.ProhibitPublicStaticMethods"})
public final class Application {
    /**
     * Entry point of application.
     * @param args Application args
     */
    public static void main(final String[] args) {
        final Path prefix = Application.init(String.format("uploads%s", UUID.randomUUID()));
        final VertxSliceServer server = new ArtipieVertxServer(prefix).server();
        final int port = server.start();
        Logger.getLogger(Application.class.getName()).log(
            Level.INFO,
            String.format("Started server on port: %d", port)
        );
    }

    /**
     * Initializes a temporary directory by specified prefix.
     * @param prefix Prefix for temporary folder
     * @return Created temporary folder.
     */
    private static Path init(final String prefix) {
        try {
            return Files.createTempDirectory(prefix);
        } catch (final IOException exc) {
            throw new UncheckedIOException("Could not initialize folder for upload", exc);
        }
    }
}

