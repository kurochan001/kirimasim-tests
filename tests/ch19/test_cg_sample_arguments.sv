/*
:name: test_cg_sample_arguments
:description: A covergroup declared with function sample takes the values to cover as arguments of sample() (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8.1 19.8 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_sample_arguments.expected
*/
// IEEE 1800-2023 §19.8.1: covergroup cg with function sample(...) replaces the
// built-in sample() with one that has the given arguments, and the coverpoints
// can use those arguments. So each call covers the value passed to it, whatever
// module variable of the same type holds.

module test_cg_sample_arguments;
  bit [1:0] unused = 2'd3;

  covergroup cg with function sample(bit [1:0] x);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup

  cg inst;

  initial begin
    inst = new;
    inst.sample(2'd1);
    $display("after sample(1): %0.2f", inst.get_inst_coverage());
    inst.sample(2'd1);
    $display("after sample(1) again: %0.2f", inst.get_inst_coverage());
    inst.sample(2'd2);
    $display("after sample(2): %0.2f", inst.get_inst_coverage());
  end
endmodule
