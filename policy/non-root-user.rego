package main

deny contains msg if {
  input.kind == "deployment"
  input.spec.user == "root"
  msg := "container must not run as root"
}
