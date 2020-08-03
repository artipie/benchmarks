FROM hashicorp/terraform
RUN apk add --no-cache python3 bash
COPY . ./benchmarks
WORKDIR /benchmarks
ENTRYPOINT ["/benchmarks/entry-point.py"]
