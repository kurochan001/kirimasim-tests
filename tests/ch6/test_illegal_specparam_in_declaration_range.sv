/*
:name: test_illegal_specparam_in_declaration_range
:description: a specparam cannot be part of the range specification of a declaration
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed range of v uses the specparam W
:expected_stderr_regex: test_illegal_specparam_in_declaration_range\.sv:22:
*/
// IEEE 1800-2023 6.20.5: a specparam may appear in any expression that is not
// assigned to a parameter and is not part of the range specification of a
// declaration. The packed range of v uses W, a specparam, so the declaration
// is illegal. Icarus Verilog 13.0 accepts it with only a warning about using
// the specparam in a constant expression; Verilator 5.052 rejects the range.

module test_illegal_specparam_in_declaration_range;
  specparam W = 4;
  logic [W:0] v;   // illegal: specparam in a declaration range

  initial
    #1 $display("v=%b", v);
endmodule
