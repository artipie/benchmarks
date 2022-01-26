/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/artipie-file/LICENCE.txt
 */
package com.artipie.file;

import com.artipie.asto.Storage;
import com.artipie.asto.fs.FileStorage;
import com.artipie.files.FilesSlice;
import com.artipie.http.auth.Authentication;
import com.artipie.http.auth.Permissions;
import com.artipie.http.rt.ByMethodsRule;
import com.artipie.http.rt.RtRule;
import com.artipie.http.rt.RtRulePath;
import com.artipie.http.rt.SliceRoute;
import com.artipie.vertx.VertxSliceServer;
import io.vertx.reactivex.core.Vertx;
import java.nio.file.Path;

/**
 * Vertx server for simple Artipie server.
 * @since 0.1
 * @checkstyle ClassDataAbstractionCouplingCheck (500 lines)
 */
public final class ArtipieVertxServer {
    /**
     * Instance of Vertx.
     */
    private static final Vertx VERTX = Vertx.vertx();

    /**
     * Port for server.
     */
    private final int port;

    /**
     * Prefix for storage folder.
     */
    private final Path prefix;

    /**
     * Storage.
     */
    private final Storage storage;

    /**
     * Ctor with default specified port.
     * @param prefix Prefix for storage folder
     * @checkstyle MagicNumberCheck (5 lines)
     */
    ArtipieVertxServer(final Path prefix) {
        this(prefix, 8080);
    }

    /**
     * Ctor.
     * @param prefix Prefix for storage folder
     * @param port Port for server
     */
    ArtipieVertxServer(final Path prefix, final int port) {
        this.prefix = prefix;
        this.storage = new FileStorage(prefix);
        this.port = port;
    }

    /**
     * Obtains instance of configured server.
     * @return Configured server.
     */
    VertxSliceServer server() {
        return new VertxSliceServer(
            ArtipieVertxServer.VERTX,
            new SliceRoute(
                new RtRulePath(
                    new RtRule.All(
                        ByMethodsRule.Standard.GET,
                        new RtRule.ByPath("/clean")
                    ),
                    new CleanSlice(this.prefix)
                ),
                new RtRulePath(
                    RtRule.FALLBACK,
                    new FilesSlice(
                        this.storage,
                        Permissions.FREE,
                        Authentication.ANONYMOUS
                    )
                )
            ),
            this.port
        );
    }
}
