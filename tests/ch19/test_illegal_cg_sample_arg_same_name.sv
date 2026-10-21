/*
:name: test_illegal_cg_sample_arg_same_name
:description: A formal argument of an overridden sample method cannot have the name of a formal argument of the covergroup (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: k is an argument of both the covergroup and its sample method
:expected_stderr_regex: test_illegal_cg_sample_arg_same_name\.sv:22:
*/
// IEEE 1800-2023 §19.8.1: the formal arguments of an overridden sample method
// belong to the same lexical scope as the formal arguments of the covergroup,
// those that new takes, so it is an error to give the same name in both
// lists. Here both declare k; the coverpoint uses only the other sample
// argument m. Icarus Verilog 13.0 does not support covergroups, so the syntax
// error it reports on that line does not count.

module test_illegal_cg_sample_arg_same_name;
  covergroup cg (int k) with function sample (int k, bit [1:0] m);   // illegal: k twice
    cp: coverpoint m { bins b[] = {[0:3]}; }
  endgroup

  cg inst = new(1);

  initial begin
    inst.sample(2, 1);
    $display("%.2f", inst.get_inst_coverage());
  end
endmodule
