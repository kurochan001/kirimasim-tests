/*
:name: test_illegal_default_disable_iff_twice_interface
:description: two default disable iff declarations in the same interface are an error (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface ddi_if declares default disable iff twice in its own scope
:expected_stderr_regex: test_illegal_default_disable_iff_twice_interface\.sv:26:
*/
// IEEE 1800-2023 §16.15: a module, interface or program declaration or a
// generate block can hold at most one default disable iff declaration; a
// second one in the same scope is an error. The interface ddi_if declares
// two. The module that instantiates it declares none.
// Icarus Verilog 13.0 does not support concurrent assertions, so its error
// does not count.

interface ddi_if (input logic clk);
  logic rst_a = 0, rst_b = 0, v = 1;

  default disable iff (rst_a);
  a_i: assert property (@(posedge clk) v);
  default disable iff (rst_b);   // illegal: a second one in the interface
endinterface

module test_illegal_default_disable_iff_twice_interface;
  logic clk = 0;
  ddi_if u (clk);
endmodule
