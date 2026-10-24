/*
:name: test_illegal_udp_all_x_entry_not_x
:description: A UDP table entry whose inputs are all x must give the output x (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: a table entry with all inputs x gives the output 1
:expected_stderr_regex: test_illegal_udp_all_x_entry_not_x\.sv:25:
*/
// IEEE 1800-2023 §29.3.4: if all input values of a table entry are
// specified as x, the output state of the entry shall be x. The last
// entry of this combinational UDP has x for both inputs and 1 as output.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

primitive test_illegal_udp_all_x_entry_not_x_p(y, a, b);
  output y;
  input a, b;
  table
    0 0 : 0;
    1 1 : 1;
    x x : 1;   // illegal: all inputs x, output not x
  endtable
endprimitive

module test_illegal_udp_all_x_entry_not_x;
  logic a = 0, b = 0;
  wire y;
  test_illegal_udp_all_x_entry_not_x_p u(y, a, b);
endmodule
