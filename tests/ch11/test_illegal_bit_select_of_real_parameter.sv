/*
:name: test_illegal_bit_select_of_real_parameter
:description: a bit-select of a real parameter is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bit-select is applied to the real parameter RP
:expected_stderr_regex: test_illegal_bit_select_of_real_parameter\.sv:26:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a real variable
// or of a real parameter is illegal. RP is a parameter of type real, and
// RP[0] selects a bit of it; the same bit-select of the parameter VP, whose
// type is a logic vector, is legal.

module test_illegal_bit_select_of_real_parameter;
  parameter real RP = 2.5;
  parameter logic [7:0] VP = 8'h01;
  logic a, b;

  initial begin
    a = VP[0];
    b = RP[0];   // illegal: bit-select of a real parameter
  end
endmodule
