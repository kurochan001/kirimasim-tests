/*
:name: test_variable_initializer_is_not_continuous
:description: an initializer in a variable declaration sets the value once, before the procedures start, and the variable keeps it until it is assigned, unlike the assignment in a net declaration, which keeps driving the net (IEEE 1800-2023 Section 10.5)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.5 10.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_initializer_is_not_continuous.expected
*/
// IEEE 1800-2023 §10.5: an assignment in the declaration of a variable is
// an initialization, not a continuous assignment: it has no duration, and
// the variable holds the value until the next assignment to it. A static
// variable gets this value before any initial or always procedure starts.
// An assignment in a net declaration is a continuous assignment (10.3.1).
//
// v = A0 + 1 is a variable initialization (A0 is a constant, so the result
// does not depend on the order of the initializations, which the standard
// leaves open), and w = a + 1 a net declaration assignment, with a starting
// at A0. An initial procedure sees v = 2 at time 0 already. When a changes,
// w follows and v keeps 2; a procedural assignment then changes v.

module test_variable_initializer_is_not_continuous;
  localparam logic [7:0] A0 = 8'd1;
  logic [7:0] a = A0;
  logic [7:0] v = A0 + 8'd1;
  wire [7:0] w = a + 8'd1;

  initial begin
    $display("t=0: v=%0d", v);
    #1 $display("t=1: v=%0d w=%0d", v, w);
    a = 8'd10;
    #1 $display("a=10: v=%0d w=%0d", v, w);
    v = 8'd50;
    a = 8'd20;
    #1 $display("v=50, a=20: v=%0d w=%0d", v, w);
  end
endmodule
