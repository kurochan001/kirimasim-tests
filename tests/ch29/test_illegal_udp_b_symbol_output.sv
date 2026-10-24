/*
:name: test_illegal_udp_b_symbol_output
:description: The UDP symbol b cannot be used in an output field (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output field of a table entry is b
:expected_stderr_regex: test_illegal_udp_b_symbol_output\.sv:23:
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: b stands for 0 and 1 and is allowed
// in input fields and in the current state field, not in the output
// field. The second entry of this combinational UDP has b as its output.

primitive test_illegal_udp_b_symbol_output_p(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : b;   // illegal: b in the output field
  endtable
endprimitive

module test_illegal_udp_b_symbol_output;
  logic a = 0;
  wire y;
  test_illegal_udp_b_symbol_output_p u(y, a);
endmodule
