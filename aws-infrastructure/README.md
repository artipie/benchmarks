# aws-infrastructure

This directory contains files for running 2 AWS instances(`client` and `server`) for benchmarking needs.

To start use `start.sh`:

```bash
$ ./start.sh
```

The following env variables are exported during the script run:

```bash
echo "$private_client_ip_addr"
echo "$private_server_ip_addr"
echo "$public_client_ip_addr"
echo "$public_server_ip_addr"
```

Connect to client instance with ssh:

```bash
$ ssh -i aws_ssh_key ubuntu@$public_client_ip_addr
```

In order to stop use `stop.sh`:

```bash
$ ./stop.sh
```