/*
:name: test_checker_package_context
:description: The defaults $inferred_clock and $inferred_disable of a checker declared in a package take the default clocking and default disable iff of each scope that instantiates it (IEEE 1800-2023 Section 17.4)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.4 17.2 17.3 16.14.7 14.12 16.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_package_context.expected
*/
// IEEE 1800-2023 §17.4, §16.14.7: $inferred_clock and $inferred_disable may be
// the whole default value of a formal of type event or of another type. The
// event expression is the default clocking event at the location of the
// checker instance, and the disable condition is the default disable iff of
// the scope that includes the instance. The checker hold_high is declared in a
// package and instantiated in two modules that have different default
// clockings and release their reset at different times. Instance 1 sees the
// slow clock (edges at 5, 15, 25, ...) and fails at 15, where its reset was
// released at 12 and sig was made 0 at 11. Instance 2 sees the fast clock
// (edges at 6, 18, 30, ...) and fails at 42, where its reset was released at
// 24 and sig was made 0 at 31. Neither simulator release reproduces this:
// Icarus Verilog 13.0 does not support checkers, and Verilator 5.052 reports
// $inferred_clock as unsupported, so the expected output follows the standard.

`timescale 1ns/1ns

package chk_context_pkg;
  checker hold_high(input logic sig, input int id,
                    event clock = $inferred_clock,
                    logic reset = $inferred_disable);
    a1: assert property (@clock disable iff (reset) sig)
      else $display("checker %0d at %0d: sig low", id, $time);
  endchecker
endpackage

module ctx_slow(input logic clk, input logic ok);
  logic rst = 1;
  default clocking @(posedge clk); endclocking
  default disable iff (rst);
  chk_context_pkg::hold_high c(.sig(ok), .id(1));
  initial #12 rst = 0;
endmodule

module ctx_fast(input logic clk, input logic ok);
  logic rst = 1;
  default clocking @(posedge clk); endclocking
  default disable iff (rst);
  chk_context_pkg::hold_high c(.sig(ok), .id(2));
  initial #24 rst = 0;
endmodule

module test_checker_package_context;
  logic slow_clk = 0, fast_clk = 0;
  logic slow_ok = 1, fast_ok = 1;

  always #5 slow_clk = ~slow_clk;   // edges at 5, 15, 25, ...
  always #6 fast_clk = ~fast_clk;   // edges at 6, 18, 30, ...

  ctx_slow slow(.clk(slow_clk), .ok(slow_ok));
  ctx_fast fast(.clk(fast_clk), .ok(fast_ok));

  initial begin
    #11 slow_ok = 0;
    #9 slow_ok = 1;      // 20
    #11 fast_ok = 0;     // 31
    #20 fast_ok = 1;     // 51
    #20 $finish;         // 60
  end
endmodule
