/*
:name: test_inferred_disable_default_and_none
:description: $inferred_disable returns the default disable condition in scope, or 1'b0 when there is none, and the expression is substituted at the place where the property is instantiated (IEEE 1800-2023 Sections 16.14.7 and 16.15)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.7 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inferred_disable_default_and_none.expected
*/
// IEEE 1800-2023 §16.14.7: $inferred_disable returns the disable condition from
// the default disable iff declaration whose scope includes the call, and
// 1'b0 if there is none; the call is replaced by the inferred expression at
// the point where the property, sequence or checker is instantiated. §16.15:
// the scope of a default disable iff does not extend into an instance of a
// module. The property p_fail has a formal dis that defaults to
// $inferred_disable and disables its attempt when dis is true. The top module
// declares default disable iff rst, so its assertion gets rst and is disabled
// at the ticks 5 and 25, where rst is high, and fails at 15 and 35. The
// module ip_sub is declared outside top and has no default disable iff, so
// its instance u1 gets 1'b0 and its assertion fails at every tick, including
// 5 and 25. A tool that let the parent default reach the instance, or that
// substituted the condition at the property declaration in the package,
// would disable the instance attempts too.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support $inferred_disable as a default, so the expected
// values come from the cited clauses.

`timescale 1ns/1ns

package ip_dis;
  property p_fail(x, dis = $inferred_disable);
    disable iff (dis) x;
  endproperty
endpackage

module ip_sub(input logic clk);
  import ip_dis::*;
  int fails = 0;

  a_sub: assert property (@(posedge clk) p_fail(1'b0)) else fails++;
endmodule

module test_inferred_disable_default_and_none;
  logic clk = 0, rst = 0;
  int top_fails = 0;

  import ip_dis::*;

  default disable iff rst;

  ip_sub u1(.clk(clk));

  always #5 clk = ~clk;   // rising edges at 5, 15, 25 and 35

  initial begin
    rst = 1;
    #12 rst = 0;
    #8 rst = 1;
    #10 rst = 0;
  end

  a_top: assert property (@(posedge clk) p_fail(1'b0)) else top_fails++;

  initial begin
    #38;
    $display("top failures %0d, sub failures %0d", top_fails, u1.fails);
    $finish;
  end
endmodule
