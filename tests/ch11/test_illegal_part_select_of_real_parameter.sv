/*
:name: test_illegal_part_select_of_real_parameter
:description: a part-select of a real parameter is illegal (IEEE 1800-2023 Section 11.5.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a part-select is applied to the real parameter RP
:expected_stderr_regex: test_illegal_part_select_of_real_parameter\.sv:26:
*/
// IEEE 1800-2023 §11.5.1: a bit-select or a part-select of a real variable
// or of a real parameter is illegal. RP is a parameter of type real, and
// RP[1:0] is a part-select of it; the same part-select of the parameter VP,
// whose type is a logic vector, is legal.

module test_illegal_part_select_of_real_parameter;
  parameter real RP = 6.0;
  parameter logic [7:0] VP = 8'h06;
  logic [1:0] a, b;

  initial begin
    a = VP[1:0];
    b = RP[1:0];   // illegal: part-select of a real parameter
  end
endmodule
