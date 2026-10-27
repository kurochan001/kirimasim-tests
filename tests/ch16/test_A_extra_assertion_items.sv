/*
:name: test_A_extra_assertion_items
:description: Assertion items are concurrent assertions or optionally labeled deferred immediate assertions, procedural assertions are concurrent, immediate or checker instantiation, and immediate assertions are the simple and the deferred assert, assume and cover forms (IEEE 1800-2023 Sections 16.3 and 16.4, A.6.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 16.4 A.6.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_assertion_items.expected
*/
// IEEE 1800-2023 A.6.10, assertion_item and procedural_assertion_statement: a
// module item is a concurrent assertion item or a deferred immediate
// assertion item, which may carry a block label; a procedural statement is a
// concurrent assertion, an immediate assertion or a checker instantiation.
// The immediate forms are the simple assert, assume and cover statements and
// the deferred ones with #0 or final.
//
// c1 to c3 are concurrent items. d1 and d2 are labeled deferred items at
// module scope, one with #0 and one with final. The initial block runs the
// three simple forms and then all six deferred forms at one time unit each,
// so the two module-level lines come first and every other line has its own
// time. The concurrent cover counts one match at the tick at 5. All checks
// pass, so n is 1.
//
// Icarus Verilog 13.0 has neither concurrent nor deferred assertions, so the
// expected output is recorded with the 5.052 release of Verilator.

`timescale 1ns/1ns
module test_A_extra_assertion_items;
  logic clk = 0, a = 1;
  int n = 0;

  always #5 clk = ~clk;

  c1: assert property (@(posedge clk) a);
  c2: assume property (@(posedge clk) a);
  c3: cover property (@(posedge clk) a) n++;

  d1: assert #0 (a) $display("deferred0");
  d2: assume final (a) $display("deferred_final");

  initial begin
    #1 assert (a) $display("simple_assert");
    #1 assume (a) $display("simple_assume");
    #1 cover (a) $display("simple_cover");
    #1 assert #0 (a) $display("proc_assert0");
    #1 assume #0 (a) $display("proc_assume0");
    #1 cover #0 (a) $display("proc_cover0");
    #1 assert final (a) $display("proc_assert_final");
    #1 assume final (a) $display("proc_assume_final");
    #1 cover final (a) $display("proc_cover_final");
    #1 $display("n=%0d", n);
    $finish;
  end
endmodule
