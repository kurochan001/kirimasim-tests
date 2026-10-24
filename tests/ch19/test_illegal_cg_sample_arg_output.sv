/*
:name: test_illegal_cg_sample_arg_output
:description: A formal argument of an overridden sample method cannot have the output direction (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sample argument v is declared with the output direction
:expected_stderr_regex: test_illegal_cg_sample_arg_output\.sv:22:
*/
// IEEE 1800-2023 §19.8.1: formal arguments of an overridden sample method
// shall not designate an output direction. Here v is an output argument,
// used only in a coverpoint. Icarus Verilog 13.0 does not support covergroups,
// so the syntax error it reports on that line does not count.

module test_illegal_cg_sample_arg_output;
  int x;

  covergroup cg with function sample (output int v);   // illegal: output argument
    cp: coverpoint v { bins b[] = {[0:3]}; }
  endgroup

  cg inst = new();

  initial begin
    inst.sample(x);
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule
