/*
:name: test_illegal_default_disable_iff_twice_generate
:description: two default disable iff declarations in the same generate block are an error (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block g declares default disable iff twice in its own scope
:expected_stderr_regex: test_illegal_default_disable_iff_twice_generate\.sv:32:
*/
// IEEE 1800-2023 §16.15: a module, interface or program declaration or a
// generate block can hold at most one default disable iff declaration; a
// second one in the same scope is an error. The module declares one, and
// the generate block g overrides it with its own, which is legal. g then
// declares a second one, which is the error.
// Icarus Verilog 13.0 does not support concurrent assertions, so its error
// does not count.

module test_illegal_default_disable_iff_twice_generate;
  logic clk = 0, rst_m = 0, rst_a = 0, rst_b = 0, v = 1;

  default disable iff (rst_m);

  a_m: assert property (@(posedge clk) v);

  if (1) begin : g
    default disable iff (rst_a);
    a_g: assert property (@(posedge clk) v);
    default disable iff (rst_b);   // illegal: a second one in g
  end
endmodule
