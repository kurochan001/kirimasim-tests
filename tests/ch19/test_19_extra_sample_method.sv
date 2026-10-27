/*
:name: test_19_extra_sample_method
:description: The built-in void sample() method takes one sample of every item of its covergroup, so coverage changes only when it is called (IEEE 1800-2023 Section 19.8)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_sample_method.expected
*/
// IEEE 1800-2023 §19.8: void sample() takes a sample of the covergroup, that
// is, it samples every coverpoint and cross of the group once. The coverpoint
// cp has the two bins b[0] and b[1]. No sample has been taken before the first
// call, so no bin is covered; a call with a = 0 covers one of the two bins and
// a call with a = 1 covers the other. §19.11.1 gives the coverage of a
// coverpoint with user-defined bins as covered bins divided by bins, and the
// group has only cp, so the three values are 0, 50 and 100 percent.

module test_19_extra_sample_method;
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a { bins b[] = {[0:1]}; }
  endgroup

  cg g;

  initial begin
    g = new;
    $display("before sample: %0.2f", g.get_inst_coverage());
    a = 0;
    g.sample();
    $display("one of two bins, below 100: %0d", g.get_inst_coverage() < 100.0);
    a = 1;
    g.sample();
    $display("after both bins: %0.2f", g.get_inst_coverage());
  end
endmodule
