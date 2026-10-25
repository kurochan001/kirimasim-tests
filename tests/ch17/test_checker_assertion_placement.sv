/*
:name: test_checker_assertion_placement
:description: A static checker's concurrent assertion is monitored at every clock and its deferred assertion whenever the expression changes, a static assertion of a checker nested in another checker follows the parent instance and becomes procedural when the parent is instantiated in procedural code, and a concurrent assertion written in a checker procedure is queued only when the procedure reaches it (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.5 16.14.6 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assertion_placement.expected
*/
// IEEE 1800-2023 17.3: static assertion statements of a checker are treated as
// if they appeared at the instantiation point. A static checker's concurrent
// assertions are continually monitored and begin at each leading clock event,
// and its deferred assertions are monitored whenever their expressions change.
// A checker statically instantiated in another checker is treated at the
// parent's context, so its static assertions become procedural when the
// top-level ancestor is instantiated in procedural code. A concurrent
// assertion written in a checker procedure is a procedural concurrent
// assertion (16.14.6): it is queued when the procedure reaches it and matures
// in the Observed region of that time step. d is 0, 9, 9, 4 and 9 at the
// rising clocks at 5, 15, 25, 35 and 45 and changes to 9 at 6, 18 and 38; bad
// is 1, 0, 1, 0 and 1 at those clocks; en is 1 only at the clock at 25.

`timescale 1ns/1ns

checker static_asserts(input logic clk, input logic [3:0] d,
                       output int conc_fail, output int def_fail);
  c1: assert property (@(posedge clk) d != 4'd9) else conc_fail = conc_fail + 1;
  d1: assert #0 (d != 4'd9) else def_fail = def_fail + 1;
endchecker : static_asserts

checker inner_chk(input logic clk, input logic bad, output int fails);
  i1: assert property (@(posedge clk) !bad) else fails = fails + 1;
endchecker : inner_chk

checker outer_chk(input logic clk, input logic bad, output int fails);
  inner_chk u_inner(.clk(clk), .bad(bad), .fails(fails));
endchecker : outer_chk

checker proc_assert(input logic clk, input logic [3:0] d, input logic en,
                    output int fails);
  always_ff @(posedge clk)
    if (en) p1: assert property (@(posedge clk) d != 4'd9)
      else fails = fails + 1;
endchecker : proc_assert

module test_checker_assertion_placement;
  logic clk = 1'b0, en = 1'b0, bad = 1'b0;
  logic [3:0] d = 4'd0;
  int conc_fail, def_fail, n_static, n_proc, n_internal;

  always #5 clk = ~clk;

  static_asserts u_static(.clk(clk), .d(d), .conc_fail(conc_fail),
                          .def_fail(def_fail));
  outer_chk u_outer_static(.clk(clk), .bad(bad), .fails(n_static));
  always @(posedge clk)
    if (en) outer_chk u_outer_proc(.clk(clk), .bad(bad), .fails(n_proc));
  proc_assert u_proc(.clk(clk), .d(d), .en(en), .fails(n_internal));

  initial begin
    #2 bad = 1'b1;
    #4 d = 4'd9;        // 6
    #6 d = 4'd4;        // 12
    bad = 1'b0;
    #6 d = 4'd9;        // 18
    #2 en = 1'b1;       // 20
    #2 bad = 1'b1;      // 22
    #6 d = 4'd4;        // 28
    en = 1'b0;
    #4 bad = 1'b0;      // 32
    #6 d = 4'd9;        // 38
    #4 bad = 1'b1;      // 42
    #8 $display("static: concurrent=%0d deferred=%0d",
                conc_fail, def_fail);
    $display("nested: static=%0d procedural=%0d internal=%0d",
             n_static, n_proc, n_internal);
    $finish;
  end
endmodule
