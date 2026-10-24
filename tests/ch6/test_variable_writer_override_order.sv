/*
:name: test_variable_writer_override_order
:description: On a variable, force overrides a procedural assign, which overrides ordinary procedural writes; release and deassign return control in that order, a variable with a continuous assignment can also be forced, and with several procedural writers the last write decides (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 10.6.1 10.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_writer_override_order.expected
*/
// IEEE 1800-2023 §6.5: a variable can be written by any number of procedural
// statements, including procedural continuous assignments, and the last write
// decides its value. A force overrides a procedural assign, and an assign
// overrides the ordinary assignments; a force is neither a procedural nor a
// continuous assignment, so a variable that a continuous assignment writes can
// also be forced. §10.6.1, 10.6.2: while assign or force is in effect the
// expression is reevaluated when its operands change; release goes back to an
// active assign or continuous assignment, and after deassign the variable keeps
// its value until the next procedural write.
// v is written in turn by procedural assignments, assign, force, release and
// deassign; cv has one continuous assignment and is forced and released; m is
// written by two initial procedures at different times.

module test_variable_writer_override_order;
  logic [7:0] v;
  logic [7:0] a_src = 8'h11, f_src = 8'h22, c_src = 8'h33;
  logic [7:0] cv;
  logic [7:0] m;

  assign cv = c_src;

  initial begin
    v = 8'h01;
    #1 $display("procedural: v=%h", v);
    assign v = a_src;
    #1 $display("assign: v=%h", v);
    v = 8'h02;
    #1 $display("procedural write under assign: v=%h", v);
    a_src = 8'h12;
    #1 $display("assign operand changed: v=%h", v);
    force v = f_src;
    #1 $display("force over assign: v=%h", v);
    a_src = 8'h13;
    v = 8'h03;
    #1 $display("assign operand and procedural write under force: v=%h", v);
    f_src = 8'h23;
    #1 $display("force operand changed: v=%h", v);
    release v;
    #1 $display("released to the active assign: v=%h", v);
    deassign v;
    #1 $display("deassigned: v=%h", v);
    v = 8'h04;
    #1 $display("procedural after deassign: v=%h", v);
    $display("continuous: cv=%h", cv);
    force cv = 8'h44;
    c_src = 8'h34;
    #1 $display("forced over continuous: cv=%h", cv);
    release cv;
    #1 $display("released to the continuous assignment: cv=%h", cv);
  end

  initial begin
    #20 m = 8'h05;
    #4 m = 8'h07;
  end

  initial #22 m = 8'h06;

  initial begin
    #21 $display("writer 1: m=%h", m);
    #2 $display("writer 2: m=%h", m);
    #2 $display("writer 1 again: m=%h", m);
  end
endmodule
