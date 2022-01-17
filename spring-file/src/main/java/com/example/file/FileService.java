package com.example.file;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.FileSystemUtils;
import org.springframework.web.multipart.MultipartFile;

public interface FileService {

    void deleteAll();

    void save(MultipartFile file);

    Resource file(String filename);

    @Service
    class Simple implements FileService {

        private final Path root;

        public Simple() {
            this.root = this.init(String.format("uploads%s", UUID.randomUUID()));
        }

        @Override
        public void deleteAll() {
            FileSystemUtils.deleteRecursively(this.root.toFile());
        }

        @Override
        public void save(final MultipartFile file) {
            try {
                Files.copy(file.getInputStream(), this.root.resolve(file.getOriginalFilename()));
            } catch (final IOException exc) {
                throw new RuntimeException("Could not store the file. Error: ", exc);
            }
        }

        @Override
        public Resource file(final String filename) {
            try {
                final Path target = root.resolve(filename);
                final Resource resource = new UrlResource(target.toUri());
                if (resource.exists() || resource.isReadable()) {
                    return resource;
                }
                throw new RuntimeException(String.format("Could not read the file '%s'", filename));
            } catch (final MalformedURLException exc) {
                throw new RuntimeException(exc);
            }
        }

        private Path init(final String prefix) {
            try {
                return Files.createTempDirectory(prefix);
            } catch (final IOException exc) {
                throw new RuntimeException("Could not initialize folder for upload", exc);
            }
        }
    }
}
