package main

deny contains msg if {
  input.kind == "deployment"
  not input.spec.signed
  msg := "signed image required"
}
