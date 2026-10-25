/*
:name: test_concurrent_assertion_places_and_kinds
:description: concurrent assertions work as statements of an initial and an always procedure and as items of a module, an interface, a program, a generate block and a checker; assert, assume, cover property, cover sequence and restrict property statements, labeled or not, take their clocks, disable iff prefixes and action blocks (IEEE 1800-2023 Section 16.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14 16.14.1 16.14.2 16.14.3 16.14.4 16.14.6 17.2 25.3 24.3 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concurrent_assertion_places_and_kinds.expected
*/
// IEEE 1800-2023 §16.14: a concurrent assertion may be a statement of an
// always or initial procedure, or an item of a module, an interface (§25.3),
// a program (§24.3), a generate block (§27.5) or a checker (§17.2). Its forms
// are assert, assume, cover property, cover sequence and restrict property,
// each with an optional label; the first four have action blocks, and cover
// sequence takes an optional clocking event and disable iff before its
// sequence. Each assertion of the first part has its own signal t_x and fails
// (property t_x |-> 1'b0) only at the tick where t_x is high: the one in the
// initial procedure has one attempt, at the first tick (§16.14.6), the one in
// the always procedure takes its clock from the procedure. Each prints its
// place from its fail action (§16.14.1), so one line per tick, 5 to 65. In
// the second part, the labeled assert with disable iff (rst) fails at 75 and
// is disabled at 85; the unlabeled assume fails at 95 (§16.14.2); the cover
// property succeeds at 105, and the cover sequence matches at 125, while its
// match at 145 comes with rst and is not counted (§16.14.3); the restrict
// property, violated at 115, is not checked (§16.14.4). Icarus Verilog 13.0
// does not support these assertions, and the 5.052 release of Verilator does
// not support a clocked concurrent assertion in an initial procedure.

`timescale 1ns/1ns

interface place_if(input logic clk, t);
  a_if: assert property (@(posedge clk) t |-> 1'b0) else $display("%0d: interface", $time);
endinterface

program place_p(input logic clk, t);
  a_prog: assert property (@(posedge clk) t |-> 1'b0) else $display("%0d: program", $time);
endprogram

checker place_c(logic clk, logic t);
  a_chk: assert property (@(posedge clk) t |-> 1'b0) else $display("%0d: checker", $time);
endchecker

module test_concurrent_assertion_places_and_kinds;
  logic clk = 0, rst = 0;
  logic t_init = 0, t_alw = 0, t_mod = 0, t_if = 0, t_prog = 0, t_gen = 0, t_chk = 0;
  logic t_lab = 0, t_asm = 0, t_cov = 0, t_cs = 0, t_cs2 = 0;

  always #5 clk = ~clk;   // tick k at 10 * k - 5

  initial begin
    a_init: assert property (@(posedge clk) t_init |-> 1'b0)
      else $display("%0d: initial procedure", $time);
  end

  always @(posedge clk) begin
    a_alw: assert property (t_alw |-> 1'b0) else $display("%0d: always procedure", $time);
  end

  a_mod: assert property (@(posedge clk) t_mod |-> 1'b0) else $display("%0d: module", $time);

  place_if u_if(clk, t_if);
  place_p u_prog(clk, t_prog);

  if (1) begin : g_blk
    a_gen: assert property (@(posedge clk) t_gen |-> 1'b0)
      else $display("%0d: generate block", $time);
  end

  place_c u_chk(clk, t_chk);

  a_lab: assert property (@(posedge clk) disable iff (rst) t_lab |-> 1'b0)
    else $display("%0d: labeled assert property with disable iff", $time);
  assume property (@(posedge clk) !t_asm) else $display("%0d: assume property", $time);
  c_prop: cover property (@(posedge clk) t_cov) $display("%0d: cover property", $time);
  cover sequence (@(posedge clk) disable iff (rst) t_cs ##1 t_cs2)
    $display("%0d: cover sequence", $time);
  r_cs: restrict property (@(posedge clk) !t_cs);

  // Raises one signal for tick k (from 10 * k - 10 to 10 * k).
  task automatic pulse(ref logic s);
    s = 1;
    #10 s = 0;
  endtask

  initial begin
    pulse(t_init);   // 5
    pulse(t_alw);    // 15
    pulse(t_mod);    // 25
    pulse(t_if);     // 35
    pulse(t_prog);   // 45
    pulse(t_gen);    // 55
    pulse(t_chk);    // 65
    pulse(t_lab);    // 75
    rst = 1;
    pulse(t_lab);    // 85, disabled
    rst = 0;
    pulse(t_asm);    // 95
    pulse(t_cov);    // 105
    pulse(t_cs);     // 115
    pulse(t_cs2);    // 125
    pulse(t_cs);     // 135
    rst = 1;
    pulse(t_cs2);    // 145, disabled
    rst = 0;
    #20 $finish;
  end
endmodule
