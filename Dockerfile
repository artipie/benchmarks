FROM hashicorp/terraform
COPY . ./benchmarks
ENTRYPOINT ["/benchmarks/entry-point.sh"]
