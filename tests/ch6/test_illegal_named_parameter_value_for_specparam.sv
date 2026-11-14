/*
:name: test_illegal_named_parameter_value_for_specparam
:description: a named parameter value assignment of an instance cannot give a new value to a specparam, which only SDF annotation can change (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5 23.10.2.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the named parameter value assignment of instance u2 names the specparam tpd of the cell
:expected_stderr_regex: test_illegal_named_parameter_value_for_specparam\.sv:32:
*/
// IEEE 1800-2023 §6.20.5 (Table 6-11): a parameter takes a new value from a
// defparam statement or from the parameter values of an instance, while a
// specparam cannot be changed from within the language at all, only through
// SDF annotation. §23.10.2.2: a named parameter value assignment names a
// parameter of the instantiated module. The cell has the parameter P and the
// specparam tpd. Instance u1 gives P a new value by name, which is legal;
// instance u2 names tpd instead, on the marked line.
// Oracle checks: Icarus Verilog 13.0 accepts the design; the 5.054 release
// of Verilator rejects the marked line because tpd is not a parameter.

module test_illegal_named_parameter_value_for_specparam_cell;
  parameter int P = 1;
  specparam tpd = 1;
  initial $display("%m: P=%0d tpd=%0d", P, tpd);
endmodule

module test_illegal_named_parameter_value_for_specparam;
  test_illegal_named_parameter_value_for_specparam_cell #(.P(2)) u1();
  test_illegal_named_parameter_value_for_specparam_cell #(.tpd(2)) u2();   // illegal: a specparam
endmodule
