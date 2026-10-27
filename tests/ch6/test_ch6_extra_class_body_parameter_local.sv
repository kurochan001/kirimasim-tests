/*
:name: test_ch6_extra_class_body_parameter_local
:description: A parameter assignment in a class body is a localparam, so a specialization cannot override it (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.1 6.20.4 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specialization h_c#(.B(3)) overrides B, a parameter assigned in the class body
:expected_stderr_regex: test_ch6_extra_class_body_parameter_local\.sv:30:
*/
// IEEE 1800-2023 §6.20.1: all parameter assignments appearing within a class
// body become localparam declarations, whether or not the class has a
// parameter port list. A in the port list is a specialization parameter, but
// B in the body is local (§6.20.4), so the specialization on the marked line
// cannot give it a value (§8.25).
// Icarus Verilog 13.0 does not parse a parameterized class, so this test has
// no Icarus oracle.

class test_ch6_extra_class_body_parameter_local_c #(parameter int A = 1);
  parameter int B = 2;
  static function int sum();
    return A + B;
  endfunction
endclass

module test_ch6_extra_class_body_parameter_local;
  initial $display("%0d", test_ch6_extra_class_body_parameter_local_c#(.B(3))::sum());
endmodule
