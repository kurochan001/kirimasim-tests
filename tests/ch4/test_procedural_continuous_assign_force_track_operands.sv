/*
:name: test_procedural_continuous_assign_force_track_operands
:description: An active procedural assign of a variable and forces of a net and of a variable update their targets in the Active region whenever an operand of their expressions changes, and deassign and release end that, after which the targets follow the rules of their kinds (IEEE 1800-2023 Section 4.9.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.2 10.6.1 10.6.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_continuous_assign_force_track_operands.expected
*/
// IEEE 1800-2023 §4.9.2: a procedural continuous assignment, assign or
// force, is a process that is sensitive to the source elements of its
// expression; when the value of the expression changes, an update of the
// target is added to the Active region. deassign and release deactivate it.
// §10.6.1: while assign is active, procedural assignments to the variable
// have no effect, and after deassign it keeps its value until the next
// procedural assignment. §10.6.2: force overrides the drivers of a net;
// after release a net takes the value of its drivers again, and a variable
// keeps its value until it is next assigned.
// At 1, assign r = a + b, force w = a * b and force u = b - a start with
// a = 3 and b = 10. In the later steps a and b change; every display after
// a change is behind #0, which resumes in the Inactive region, after the
// Active updates. The driver c of w changes while w is forced, and r is
// written while it is assigned: neither shows. At 4 deassign and release
// end the three, and the values seen next show the rules of §10.6.
// Icarus Verilog 13.0 evaluates the right-hand sides of assign and force
// only once, when they are executed, so it keeps 13, 30 and 7. The 5.054
// release of Verilator gives this output, but not the updates for an
// operand change in the time step of the force or for an assign executed
// at time 0 (test_force_and_assign_follow_expression and
// test_sched_procedural_assign_deassign).

module test_procedural_continuous_assign_force_track_operands;
  logic [7:0] a = 8'd3, b = 8'd10, c = 8'd50;
  logic [7:0] r = 8'd0, u = 8'd0;
  wire [7:0] w;

  assign w = c;

  initial begin
    #1;
    assign r = a + b;
    force w = a * b;
    force u = b - a;
    #1 $display("t2 start: r=%0d w=%0d u=%0d", r, w, u);
    a = 8'd5;
    #0 $display("t2 a=5: r=%0d w=%0d u=%0d", r, w, u);
    #1 b = 8'd12;
    #0 $display("t3 b=12: r=%0d w=%0d u=%0d", r, w, u);
    c = 8'd99;
    r = 8'd200;
    #0 $display("t3 c=99, r written: r=%0d w=%0d u=%0d", r, w, u);
    #1;
    deassign r;
    release w;
    release u;
    #0 $display("t4 ended: r=%0d w=%0d u=%0d", r, w, u);
    a = 8'd1;
    b = 8'd2;
    #0 $display("t4 a=1 b=2: r=%0d w=%0d u=%0d", r, w, u);
    r = 8'd40;
    u = 8'd41;
    #0 $display("t4 written: r=%0d w=%0d u=%0d", r, w, u);
  end
endmodule
