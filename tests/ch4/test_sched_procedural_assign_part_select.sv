/*
:name: test_sched_procedural_assign_part_select
:description: A procedural continuous assignment to a part-select drives only those bits, overrides procedural writes to them until deassign, and leaves the other bits to procedural writes (IEEE 1800-2023 Section 4.9.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.2 10.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_procedural_assign_part_select.expected
*/
// IEEE 1800-2023 §4.9.2: an assign statement in a procedure makes a process
// that drives its target until deassign. §10.6.1: while that assignment is in
// effect, a procedural assignment to a bit it drives has no effect. Here the
// assignment drives only q[3:0], so q = 8'hff changes the high nibble and
// leaves the low nibble at c, a write to q[3:0] is ignored, and a write to
// q[7:4] works. After deassign q[3:0] the low nibble is free again. The
// right-hand side d[3:0] never changes, so the expected values do not depend
// on how often a release evaluates it; Icarus Verilog 13.0 evaluates it only
// once and says so.

module test_sched_procedural_assign_part_select;
  logic [7:0] q = 8'h00;
  logic [7:0] d = 8'h3c;

  initial begin
    assign q[3:0] = d[3:0];
    #1 $display("assigned low nibble: q=%h", q);
    q = 8'hff;
    #1 $display("whole write: q=%h", q);
    q[7:4] = 4'h5;
    #1 $display("high nibble write: q=%h", q);
    q[3:0] = 4'h0;
    #1 $display("low nibble write: q=%h", q);
    deassign q[3:0];
    #1 $display("after deassign: q=%h", q);
    q = 8'h11;
    #1 $display("new whole write: q=%h", q);
  end
endmodule
