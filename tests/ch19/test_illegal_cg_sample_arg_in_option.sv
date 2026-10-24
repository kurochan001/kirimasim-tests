/*
:name: test_illegal_cg_sample_arg_in_option
:description: A formal argument of an overridden sample method cannot be used outside coverpoint and conditional guard expressions, here in an option (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sample argument w is used to set option.weight, which is neither a coverpoint nor a guard expression
:expected_stderr_regex: test_illegal_cg_sample_arg_in_option\.sv:23:
*/
// IEEE 1800-2023 §19.8.1: a formal argument of an overridden sample method may
// only designate a coverpoint or conditional guard expression; using it in
// any other context is an error. Here the sample argument w sets
// option.weight; the coverpoint of v and its guard en are legal uses. Icarus
// Verilog 13.0 does not support covergroups, so the syntax error it reports on
// that line does not count. Version 5.052 of Verilator accepts the design.

module test_illegal_cg_sample_arg_in_option;
  covergroup cg with function sample (int v, bit en, int w);
    option.weight = w;   // illegal: a sample argument in an option
    cp: coverpoint v iff (en) { bins b[] = {[0:3]}; }
  endgroup

  cg inst = new();

  initial begin
    inst.sample(1, 1, 2);
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule
