/*
 * The MIT License (MIT) Copyright (c) 2020-2022 artipie.com
 * https://github.com/artipie/benchmarks/blob/master/spring-file/LICENCE.txt
 */
package com.artipie.spring;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.FileSystemUtils;

/**
 * Service interface for crucial operation to interact with data.
 * @since 0.1
 */
public interface DataService {
    /**
     * Deletes all data from root path.
     */
    void deleteAll();

    /**
     * Saves data to the root by specified key.
     * @param data Stream with data for saving
     * @param key Path to data
     */
    void save(InputStream data, String key);

    /**
     * Obtains resource from root by specified key.
     * @param key Key for obtaining resource
     * @return Resource by specified key.
     * @throws MalformedURLException In case of malformed key.
     * @throws FileNotFoundException In case of absence file by specified key.
     */
    Resource data(String key) throws MalformedURLException, FileNotFoundException;

    /**
     * Basic implementation for {@link DataService}.
     * @since 0.1
     */
    @Service
    class Simple implements DataService {
        /**
         * Root path for saving files.
         */
        private final Path root;

        /**
         * Ctor with random root path.
         */
        public Simple() {
            this(String.format("uploads%s", UUID.randomUUID()));
        }

        /**
         * Ctor with specified root path.
         * @param root Root path
         */
        public Simple(final String root) {
            this(Simple.init(root));
        }

        /**
         * Ctor with specified root path.
         * @param root Root path
         */
        public Simple(final Path root) {
            this.root = root;
        }

        @Override
        public void deleteAll() {
            FileSystemUtils.deleteRecursively(this.root.toFile());
        }

        @Override
        public void save(final InputStream data, final String name) {
            try {
                Files.copy(data, this.root.resolve(name));
            } catch (final IOException exc) {
                throw new UncheckedIOException(String.format("Could not store '%s'", name), exc);
            }
        }

        @Override
        public Resource data(final String key) throws MalformedURLException, FileNotFoundException {
            final Path target = this.root.resolve(key);
            final Resource resource = new UrlResource(target.toUri());
            if (resource.exists() || resource.isReadable()) {
                return resource;
            }
            throw new FileNotFoundException(String.format("Could not read data by '%s'", key));
        }

        /**
         * Initializes a temporary directory by specified key.
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
}
