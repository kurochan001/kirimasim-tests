/*
:name: test_sched_procedural_assign_deassign
:description: A procedural continuous assignment follows its right-hand side and overrides procedural assignments until deassign (IEEE 1800-2023 Section 4.9.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.2 10.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_procedural_assign_deassign.expected
*/
// IEEE 1800-2023 §4.9.2: an assign statement in a procedure makes a process
// that is sensitive to its right-hand side and updates the variable whenever
// the right-hand side changes. §10.6.1: while it is in effect, procedural
// assignments to the variable have no effect; after deassign the variable
// keeps its value until the next procedural assignment.
//
// Icarus Verilog 13.0 (which warns that it evaluates the right-hand side only
// once) and Verilator 5.052 both keep q at 2 when d changes.

module test_sched_procedural_assign_deassign;
  logic [7:0] q, d;

  initial begin
    d = 8'd1;
    q = 8'd0;
    assign q = d + 8'd1;
    #1 $display("assigned: q=%0d", q);
    d = 8'd5;
    #1 $display("d changed: q=%0d", q);
    q = 8'd99;
    #1 $display("procedural write while assigned: q=%0d", q);
    deassign q;
    #1 $display("deassigned: q=%0d", q);
    d = 8'd7;
    #1 $display("d changed after deassign: q=%0d", q);
    q = 8'd3;
    #1 $display("procedural write after deassign: q=%0d", q);
  end
endmodule
