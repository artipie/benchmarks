# Benchmarks for Files Artipie repositories.

## Hosted repository 

It provides the base functionality for working with files. It supports PUT operation to
upload files and GET operation to download.

## Upload files

This scenario tests upload files performance. There is 3 user groups. The first group
uploads small files, the second - medium-sized files and the last one - large files.
All groups working simultaneously. Uploaded files generated on-the-fly and contains
randomly generated content. Filename is the request sequence number without extension.
Files are put in folders based on this size: `small`, `medium` and `large`.

Test plan is represented by `upload-files.jmx` scenario. It has several properties 
thar allows to configure it for particular environment:

* `repository.schema` - defines URL schema of files repository, `http` by default; 
* `repository.host` - defines hostname of files repository, `<empty>` by default; 
* `repository.port` - defines port of files repository, `80` by default;
* `repository.path` - context path of files repository, `<empty>` by default. It used for 
repository managers that routes requests to concrete repository based on URL paths;
* `users.small` - simultaneous users that upload small files, 1 by default;
* `users.medium` - simultaneous users that upload medium-size files, 1 by default;
* `users.large` - simultaneous users that upload large files, 1 by default;
* `size.small` - size of the uploaded small files in kilobytes, 1 by default;
* `size.medium` - size of the uploaded medium-sized files in kilobytes, 1,024 by default;
* `size.large` - size of the uploaded large files in kilobytes, 65,536 by default (64 MB 
   doesn't looks like large file, but it's the JMeter standard HTTP Sampler restriction:
   it keeps all data in-memory so the memory consumption exceeds 2 x 64 MB x ${users.large});
* `duration` - duration of test in seconds, 300 by default. Keep in mind that both JMeter
  and server requires time to be adapted to the load. Typically, test is stabilized
  during first 30 seconds;
* `login` - login for Basic Authentication, `<empty>` by default;
* `password` - password for Basic Authentication, `<empty>` by default.

To run the test we will use docker container with JMeter inside. Run the command:
```shell script
$ docker run -it --rm --name junit -v `pwd`:`pwd` -w `pwd` justb4/jmeter:5.1.1 \
    -n -t upload-files.jmx -l results.jtl -e -o report \
    -Jrepository.host=artipie.com -Jrepository.schema=http -Jrepository.port=8080 -Jrepository.path=files \
    -Jduration=600 -Jlogin=admin -Jpassword=admin
```

### References

We will use Nexus raw hosted repository as reference installation.

### Results

TBD

## Download 
