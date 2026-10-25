/*
:name: test_proc_assign_second_assign_replaces_first
:description: an assign procedural continuous assignment to a variable that already has one first deassigns it, so only the new right-hand side drives the variable and a deassign leaves none (IEEE 1800-2023 Section 10.6.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_proc_assign_second_assign_replaces_first.expected
*/
// IEEE 1800-2023 §10.6.1: when assign is applied to a variable that already
// has an assign procedural continuous assignment, the variable is first
// deassigned and then the new procedural continuous assignment is made. A
// deassign ends the procedural continuous assignment, and the variable keeps
// its value until it is assigned again.
//
// "assign q = a;" is followed by "assign q = b;". From then on a change of a
// does not reach q and a change of b does. After "deassign q;" q keeps its
// value when a or b changes: the first assignment does not come back when
// the second one ends. A procedural write after the deassign is the
// contrast that shows q can be written again.

module test_proc_assign_second_assign_replaces_first;
  int a = 10, b = 20, q;

  initial begin
    assign q = a;
    #1 $display("assign q = a: q=%0d", q);
    assign q = b;
    #1 $display("assign q = b: q=%0d", q);
    a = 11;
    #1 $display("a=11:         q=%0d", q);
    b = 21;
    #1 $display("b=21:         q=%0d", q);
    deassign q;
    a = 12;
    b = 22;
    #1 $display("deassigned:   q=%0d", q);
    q = 5;
    a = 13;
    #1 $display("q=5, a=13:    q=%0d", q);
  end
endmodule
