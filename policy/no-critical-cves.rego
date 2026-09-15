package main

deny contains msg if {
  input.kind == "deployment"
  input.spec.critical_cves > 0
  msg := "critical CVEs must be zero"
}
