/*
:name: test_procedural_continuous_assign_and_force_forms
:description: assign and force, executed in a procedure, keep their target following the right-hand side until deassign or release ends them (IEEE 1800-2023 Section 10.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.2 10.6.1 10.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_continuous_assign_and_force_forms.expected
*/
// IEEE 1800-2023 §10.2: besides continuous and procedural assignments there
// are two forms of procedural continuous assignment, assign/deassign and
// force/release (10.6). Each is started by a statement in a procedure and
// then acts continuously until it is ended.
//
// assign v = src + 1 makes v follow src, overrides a procedural write to v,
// and after deassign v keeps its value until the next procedural assignment
// (10.6.1). force applies to the net w, whose continuous driver gives src,
// and to the variable v: both follow the forced expressions; after release w
// has the value of its driver again and v keeps its last value (10.6.2).
// Icarus Verilog 13.0 says ("sorry") that it evaluates the right-hand side
// of a procedural assign only once, so v does not follow src there.

module test_procedural_continuous_assign_and_force_forms;
  logic [3:0] src = 4'd2;
  logic [3:0] v;
  wire  [3:0] w;

  assign w = src;

  initial begin
    v = 4'd1;
    #1 assign v = src + 4'd1;
    #1 $display("assign: v=%0d", v);
    src = 4'd5;
    #1 $display("assign follows src: v=%0d", v);
    v = 4'd0;
    #1 $display("procedural write while assigned: v=%0d", v);
    deassign v;
    #1 $display("after deassign: v=%0d", v);
    v = 4'd9;
    #1 $display("procedural write after deassign: v=%0d", v);
    force w = src + 4'd2;
    force v = src - 4'd1;
    #1 $display("force: w=%0d v=%0d", w, v);
    src = 4'd8;
    #1 $display("force follows src: w=%0d v=%0d", w, v);
    release w;
    release v;
    #1 $display("after release: w=%0d v=%0d", w, v);
  end
endmodule
