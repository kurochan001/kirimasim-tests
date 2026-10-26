/*
:name: test_sva_typed_formal_assignment
:description: An assignment to a typed local formal of a sequence is made in the type of the formal and then assigned from the formal to the int actual, so 300 assigned to a byte formal leaves 44 in the actual and the comparison of the property passes (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8.1 16.8.2 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sva_typed_formal_assignment.expected
*/
// IEEE 1800-2023 Section 16.8.1: if the actual argument of a typed formal is
// a variable_lvalue, a reference to the formal is viewed through the formal's
// type, and an assignment to the formal is treated as though a subsequent
// assignment from the formal to the actual argument followed it. Section
// 16.8.2 adds that an output local formal starts each attempt unassigned and
// that its value at the completion of a match is cast to the actual's type and
// assigned to the actual.
//
// s_set has the local output formal o of type byte and assigns 300 to it. The
// assignment truncates 300 to the byte 44, and at the match the byte 44 is
// assigned to the int actual v of the property. The property then requires
// v == 44 at the next tick. a is high at the ticks 5 and 15; the attempt at 5
// assigns o at 5 and completes s_set at 15, so v becomes 44 and the comparison
// passes at 25. The attempt at 15 completes at 25 and compares at 35. A tool
// that assigned 300 to the int actual, or that did not assign the formal to
// the actual, would fail both comparisons.
// Icarus Verilog 13.0 has no concurrent assertions and Verilator 5.052 does
// not support local formal arguments of sequences, so neither produces this
// output.

`timescale 1ns/1ns

module test_sva_typed_formal_assignment;
  logic clk = 0, a = 0;
  int pass_t[$], fail_t[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, 35

  sequence s_set(local output byte o);
    (a, o = 300) ##1 (1'b1);
  endsequence

  property p;
    int v = 0;
    s_set(v) ##1 (v == 44);
  endproperty

  ap: assert property (@(posedge clk) a |-> p)
    pass_t.push_back(int'($time)); else fail_t.push_back(int'($time));

  initial begin
    $assertvacuousoff;
    #2 a = 1;                   // the ticks 5 and 15
    @(negedge clk);
    @(negedge clk) a = 0;       // the tick 25
    #16;
    $write("pass:"); foreach (pass_t[i]) $write(" %0d", pass_t[i]); $write("\n");
    $write("fail:"); foreach (fail_t[i]) $write(" %0d", fail_t[i]); $write("\n");
    $finish;
  end
endmodule
