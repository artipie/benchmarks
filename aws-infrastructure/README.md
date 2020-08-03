# aws-infrastructure

This directory contains files for running 2 AWS instances(`client` and `server`) for benchmarking needs.

To start use `start.sh`:

```bash
$ ./start.sh
```

The following env variables are exported during the script run:

```bash
echo "$PRIVATE_CLIENT_IP_ADDR"
echo "$PRIVATE_SERVER_IP_ADDR"
echo "$PUBLIC_CLIENT_IP_ADDR"
echo "$PUBLIC_SERVER_IP_ADDR"
```

Connect to client instance with ssh:

```bash
$ ssh -i aws_ssh_key ubuntu@$PUBLIC_CLIENT_IP_ADDR
```

In order to stop use `stop.sh`:

```bash
$ ./stop.sh
```