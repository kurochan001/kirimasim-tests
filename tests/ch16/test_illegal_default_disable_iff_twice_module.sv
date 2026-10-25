/*
:name: test_illegal_default_disable_iff_twice_module
:description: two default disable iff declarations in the same module are an error (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares default disable iff twice in its own scope
:expected_stderr_regex: test_illegal_default_disable_iff_twice_module\.sv:33:
*/
// IEEE 1800-2023 §16.15: a module, interface or program declaration or a
// generate block can hold at most one default disable iff declaration; a
// second one in the same scope is an error, wherever it is placed. A generate
// block is a scope of its own, so the declaration in g is legal next to the
// one of the module. The module itself then declares a second default
// disable iff, which is the error.
// Icarus Verilog 13.0 does not support concurrent assertions, so its error
// does not count.

module test_illegal_default_disable_iff_twice_module;
  logic clk = 0, rst_a = 0, rst_b = 0, rst_g = 0, v = 1;

  default disable iff (rst_a);

  if (1) begin : g
    default disable iff (rst_g);
    a_g: assert property (@(posedge clk) v);
  end

  default disable iff (rst_b);   // illegal: a second one in the module

  a_m: assert property (@(posedge clk) v);
endmodule
