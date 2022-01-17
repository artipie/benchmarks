package com.example.file;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
public class FileController {
    private FileService fileserv;

    @Autowired
    public FileController(final FileService fileserv) {
        this.fileserv = fileserv;
    }

    @PostMapping("upload")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) {
        fileserv.save(file);
        return ResponseEntity.ok(String.format("Uploaded file: %s", file.getName()));
    }

    @DeleteMapping("clean")
    public void cleanRoot() {
        fileserv.deleteAll();
    }

    @GetMapping("/files/{name}")
    public ResponseEntity<Resource> file(@PathVariable("name") String name) {
        final Resource target = fileserv.file(name);
        return ResponseEntity.ok()
            .header(
                HttpHeaders.CONTENT_DISPOSITION,
                String.format("attachment; filename=%s", target.getFilename())
            ).body(target);
    }

}
