FROM hashicorp/terraform

COPY files /benchmarks/files
COPY entry-point.sh /benchmarks/

ENTRYPOINT ["/benchmarks/entry-point.sh"]
