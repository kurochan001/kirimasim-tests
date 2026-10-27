/*
:name: test_ch6_extra_defparam_specparam
:description: A specparam cannot be modified by defparam, a language parameter-override construct (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5 23.10.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the defparam statement tries to override the specparam tpd
:expected_stderr_regex: test_ch6_extra_defparam_specparam\.sv:27:
*/
// IEEE 1800-2023 §6.20.5: unlike a parameter constant, a specify parameter
// cannot be modified from within the language; it can be modified through SDF
// annotation (Clause 32). defparam is a language construct (§23.10.1), so the
// marked line is illegal. The specparam is not an overridable parameter.
// Icarus Verilog 13.0 accepts the design, so this test has no Icarus oracle.

module test_ch6_extra_defparam_specparam_cell;
  specparam tpd = 1;
  initial $display("tpd=%0d", tpd);
endmodule

module test_ch6_extra_defparam_specparam;
  test_ch6_extra_defparam_specparam_cell u();
  defparam u.tpd = 2;   // illegal: a specparam is not a parameter
endmodule
