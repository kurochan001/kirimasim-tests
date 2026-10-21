/*
:name: test_illegal_udp_combinational_reg
:description: A combinational UDP cannot declare its output as reg (IEEE 1800-2023 Section 29.3.2)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.2 29.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the combinational UDP declares its output reg
:expected_stderr_regex: test_illegal_udp_combinational_reg\.sv:(22|23|26|27):
*/
// IEEE 1800-2023 §29.3.2: a sequential UDP declares its output as reg, and a
// combinational UDP cannot contain a reg declaration. The table has no field
// for the current state, so the UDP is combinational. A tool can report the
// reg, the output it declares, or the entries without a current state.
// Icarus Verilog 13.0 stops with an internal assertion
// (docs/simulator-differences.md).

primitive test_illegal_udp_combinational_reg_p(y, a);
  output y;   // error here
  reg y;   // illegal: reg in a combinational UDP
  input a;
  table
    0 : 1;   // error here
    1 : 0;   // error here
  endtable
endprimitive

module test_illegal_udp_combinational_reg;
  logic a = 0;
  wire y;
  test_illegal_udp_combinational_reg_p u(y, a);
endmodule
