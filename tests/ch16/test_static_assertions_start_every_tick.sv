/*
:name: test_static_assertions_start_every_tick
:description: a concurrent assert or cover written outside procedural code in a module, an interface or a program starts a new evaluation attempt at every tick of its leading clock, so attempts that overlap in time are evaluated separately (IEEE 1800-2023 Section 16.14.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.5 16.14.1 16.14.3 25.3 24.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_assertions_start_every_tick.expected
*/
// IEEE 1800-2023 §16.14.5: an assert, assume, cover or restrict statement
// outside procedural code, in a module, an interface (§25.3) or a program
// (§24.3), begins a new evaluation attempt of its property at every
// occurrence of its leading clocking event. The clock ticks six times (5 to
// 55). The assertions of 1'b1 in the module, in the interface instance and in
// the program instance pass at each tick, and their pass statements
// (§16.14.1) count the attempts; the cover property of 1'b1 in the module
// counts its successes (§16.14.3). a is high at the ticks 5 and 15 and b
// never, so the attempts of a |=> ##1 b that start at 5 and 15 are both
// running at 15 and fail separately, at 25 and 35. The program passes its
// count out through a port; it has no initial procedure, so it does not end
// the simulation.

`timescale 1ns/1ns

interface cnt_if(input logic clk);
  int n = 0;
  a_if: assert property (@(posedge clk) 1'b1) n++;
endinterface

program cnt_p(input logic clk, output int n);
  a_prog: assert property (@(posedge clk) 1'b1) n++;
endprogram

module test_static_assertions_start_every_tick;
  logic clk = 0, a = 0, b = 0;
  int n_mod = 0, n_cov = 0, n_prog;
  int f_q[$];

  cnt_if u_if(clk);
  cnt_p u_prog(clk, n_prog);

  a_mod: assert property (@(posedge clk) 1'b1) n_mod++;
  c_mod: cover property (@(posedge clk) 1'b1) n_cov++;
  a_ovl: assert property (@(posedge clk) a |=> ##1 b) else f_q.push_back($time);

  initial begin
    repeat (12) #5 clk = ~clk;   // ticks at 5, 15, 25, 35, 45 and 55
  end

  initial begin
    a = 1;      // sampled at 5 and 15
    #20 a = 0;
    #40;
    $display("attempts: module %0d, cover %0d, interface %0d, program %0d", n_mod, n_cov,
             u_if.n, n_prog);
    $write("a |=> ##1 b failures at");
    foreach (f_q[i]) $write(" %0d", f_q[i]);
    $display("");
    $finish;
  end
endmodule
