/*
:name: test_default_disable_iff_nested_module
:description: the default disable iff of a module reaches the assertions of a module declared inside it, and a nested module that declares its own default disable iff uses that one instead (IEEE 1800-2023 Section 16.15)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.15 23.4 16.12 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_disable_iff_nested_module.expected
*/
// IEEE 1800-2023 §16.15: the default disable iff of a module extends to the
// module declarations nested in it (§23.4), unless such a declaration has a
// default disable iff of its own, which then applies within it and overrides
// the outer one. nested_m and nested_own_m are declared in the top module and
// instantiated there; their names clk, a and b are those of the top module
// (§23.4). The top default is rst; nested_own_m declares default disable iff
// r_nm. Every assertion checks a |=> b, with a high at one tick of each phase
// and b always low, so each attempt fails one tick later (§16.12) unless it is
// disabled. In each phase one disable signal is high during that attempt; the
// fail actions (§16.14.1) count the failures, and each line names the
// assertions that failed in that phase. Icarus Verilog 13.0 does not support
// these assertions, and the 5.052 release of Verilator does not support
// nested module declarations.

`timescale 1ns/1ns

module test_default_disable_iff_nested_module;
  logic clk = 0, a = 0, b = 0, rst = 0, r_nm = 0;
  int f_top = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  default disable iff rst;

  a_top: assert property (@(posedge clk) a |=> b) else f_top++;

  module nested_m;
    int f = 0;
    a_nested: assert property (@(posedge clk) a |=> b) else f++;
  endmodule
  nested_m u_nested();

  module nested_own_m;
    int f = 0;
    default disable iff r_nm;
    a_nested_own: assert property (@(posedge clk) a |=> b) else f++;
  endmodule
  nested_own_m u_nested_own();

  int last[3];

  // Names the assertions whose failure count grew since the last call.
  function automatic string failed();
    int now[3] = '{f_top, u_nested.f, u_nested_own.f};
    string names[3] = '{"top", "nested", "nested_own"};
    string s = "";
    foreach (now[i]) if (now[i] != last[i]) s = {s, " ", names[i]};
    last = now;
    return s;
  endfunction

  // One phase of 30 time units: a for the tick at +5, which is checked at +15;
  // the disable signal chosen by k is high from +0 to +20.
  task automatic run_phase(int k, string what);
    {rst, r_nm} = 2'b10 >> k;
    a = 1;
    #10 a = 0;
    #10 {rst, r_nm} = 2'b00;
    #8 $display("%s high: failed:%s", what, failed());
    #2;
  endtask

  initial begin
    run_phase(0, "rst");
    run_phase(1, "r_nm");
    run_phase(2, "nothing");
    $finish;
  end
endmodule
