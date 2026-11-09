/*
:name: test_global_clocking_unnamed_and_end_label
:description: a global clocking declaration may omit its name, since $global_clock refers to it, and a named one may repeat its name after endclocking; neither has clocking items (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.14 A.6.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_clocking_unnamed_and_end_label.expected
*/
// IEEE 1800-2023 §14.14, A.6.11: a global clocking declaration is global
// clocking, an optional name, a clocking event and a semicolon, followed
// directly by endclocking and optionally by a colon and the same name. The
// name may be left out because $global_clock refers to the global clocking
// event. gc_unnamed declares an unnamed global clocking on the posedge of c,
// and gc_labeled a named one, gl, on the negedge of c, closed by
// endclocking : gl. Each counts the events of @($global_clock) in its own
// instance. clk rises at 5, 15, 25, 35 and falls at 10, 20, 30, so by 38 the
// first count is 4 and the second 3. A simulator that rejects either form
// does not compile the test. The counts start after time 0: the port net c
// may change from z to 0 at time 0 (4.9.1), which is a negedge, and whether
// the always procedure already waits then is not fixed. §14.3 lets only a
// default clocking block be unnamed, but §14.14 explicitly allows an unnamed
// global clocking, and the specific rule is the one for global clocking.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module gc_unnamed(input logic c);
  int n = 0;
  global clocking @(posedge c); endclocking
  always @($global_clock) if ($time > 0) n++;
endmodule

module gc_labeled(input logic c);
  int n = 0;
  global clocking gl @(negedge c); endclocking : gl
  always @($global_clock) if ($time > 0) n++;
endmodule

module test_global_clocking_unnamed_and_end_label;
  logic clk = 0;

  always #5 clk = ~clk;

  gc_unnamed u(clk);
  gc_labeled l(clk);

  initial begin
    #38;
    $display("unnamed global clocking on posedge: %0d events", u.n);
    $display("global clocking gl with end label on negedge: %0d events", l.n);
    $finish;
  end
endmodule
