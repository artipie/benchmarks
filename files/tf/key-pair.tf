resource "aws_key_pair" "perf_key_pair" {
  key_name   = "perf-key"
  public_key = file("id_rsa_perf.pub")
}