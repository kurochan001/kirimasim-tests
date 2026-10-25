/*
:name: test_force_and_assign_follow_expression
:description: An active force or procedural assign statement is a process sensitive to its expression, and a change of the expression updates the target in the Active region, until release or deassign ends it (IEEE 1800-2023 Section 4.9.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.2 10.6.1 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_and_assign_follow_expression.expected
*/
// IEEE 1800-2023 §4.9.2: a procedural continuous assignment, assign (§10.6.1)
// or force (§10.6.2), is a process sensitive to the source elements of its
// expression; a change of the expression adds an active update event for
// the target. deassign and release end it.
// The net w has a continuous driver a; force w = a + b overrides it. Each
// change of a or b is followed by #0, which resumes in the Inactive region,
// after the Active update of the target: w follows at once. After release,
// w has the driver's value again. assign r = a * 2 makes r follow a until
// deassign, after which r keeps its value when a changes.
// Icarus Verilog 13.0 evaluates the right-hand sides of force and assign only
// once (w stays 3 and r stays 20), and the release 5.052 of Verilator does
// not update the forced net w when a or b changes (w stays 3).

module test_force_and_assign_follow_expression;
  logic [7:0] a = 8'd1, b = 8'd2, r;
  wire [7:0] w;

  assign w = a;

  initial begin
    #1 force w = a + b;
    #0 $display("forced: w=%0d", w);
    a = 8'd10;
    #0 $display("a=10: w=%0d", w);
    b = 8'd20;
    #0 $display("b=20: w=%0d", w);
    release w;
    #0 $display("released: w=%0d", w);
    assign r = a * 2;
    #0 $display("assign: r=%0d", r);
    a = 8'd7;
    #0 $display("a=7: r=%0d w=%0d", r, w);
    deassign r;
    a = 8'd8;
    #0 $display("deassigned, a=8: r=%0d", r);
  end
endmodule
