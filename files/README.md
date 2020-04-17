# Benchmarks for Files Artipie repositories.

## How to run tests

Tests can be run in two ways:
1. **Manual management infrastructure**. In this case the user is fully responsible
to create environment for the tests. After environment is created and initially setup,
user can run test scenarios with JMeter and get results;
2. **AWS on-demand infrastructure**. There is a way to deploy all infrastructure 
automatically in AWS, run tests and destroy the infrastructure. `run.sh` script handles
full life-cycle for the task. It creates infrastructure with Terraform, runs the test,
downloads the results and destroy infrastructure.

### AWS on-demand infrastructure 

To use `run.sh` you need:
1. Setup AWS credentials. There are two ways:
   * Create `terraform.tfvars` file with the following content:
   ```hcl-terraform
    access_key = "<AWS_ACCESS_KEY>"
    secret_key = "<AWS_SECRET_KEY>"
   ```
   * Set environment variables:
   ```
   TF_VAR_access_key=<AWS_ACCESS_KEY>
   TF_VAR_secret_key=<AWS_SECRET_KEY>
   ```
   There are number of parameters for terraform you can see in `tf/variables.tf` file
   you may want to override. You can do it with the same ways (file, env).
2. Execute `run.sh`:
   ```shell script
   $ ./run.sh <scenario.jmx> (artipie|sonatype) [<version>]
   ```
   where 
   - **<scenario.jmx>** - JMeter scenario to be executed;
   - **(artipie|sonatype)** - repository to be tested. Only artipie and 
     sonatype are supported;
   - **<version>** - version of repository. It corresponds to docker tag
     for the repository image. It's optional param, *latest* by default.
     
     *Keep in mind that artipie is not published with latest tag now (actual
     for 0.1.2) version*.
   
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
