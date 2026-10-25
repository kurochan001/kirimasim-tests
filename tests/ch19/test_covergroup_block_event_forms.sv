/*
:name: test_covergroup_block_event_forms
:description: A covergroup whose coverage event is a block event expression is sampled when the named task begins and when the named block ends, the two joined by or, and both samples reach their bins (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 A.2.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_covergroup_block_event_forms.expected
*/
// IEEE 1800-2023 §19.3 with A.2.11: a coverage event is a clocking event, a
// sample method declared with function sample, or @@ around a block event
// expression. That expression joins its operands with or, and an operand is
// begin or end followed by a hierarchical task, function or block name, or a
// method name. Here the covergroup is sampled when the task work begins, at
// which bv is still 0, and when the named block job ends, after bv was set to
// 2; the task also sets bv to 1 before it returns, but no event watches that.
//
// The coverpoint has one bin for 1 and one for 2. The sample at the start of
// work covers neither, the one at the end of job covers two, and the bin one
// is never covered, so the coverage is 50. A separate initial block prints
// after job has ended. Icarus Verilog 13.0 has no covergroups, and the 5.052
// release of the other tool does not sample at an end event, so the expected
// output follows the standard.

module test_covergroup_block_event_forms;
  bit bv = 0;

  task automatic work();
    bv = 1;
  endtask

  covergroup cg @@(begin work or end job);
    cp: coverpoint bv { bins one = {1}; bins two = {2}; }
  endgroup

  cg g = new;

  initial begin : job
    bv = 0;
    work();
    bv = 2;
  end

  initial #10 $display("block event %0.0f", g.get_inst_coverage());
endmodule
