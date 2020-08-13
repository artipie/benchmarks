FROM hashicorp/terraform
RUN apk add --no-cache python3 bash
COPY . ./benchmarks
ENTRYPOINT ["/benchmarks/entry-point.py"]
