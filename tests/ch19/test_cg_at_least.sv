/*
:name: test_cg_at_least
:description: With option.at_least, a bin counts as covered only after that many hits (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_at_least.expected
*/
// IEEE 1800-2023 §19.7: option.at_least is the smallest number of hits for which
// a bin is covered; a bin hit fewer times is not covered (19.11.1). With
// at_least = 2, one hit leaves a bin uncovered and a second hit covers it.
//
// Version 5.052 of Verilator counts a bin as covered after one hit; Icarus
// Verilog 13.0 does not compile covergroups.

module test_cg_at_least;
  bit p;

  covergroup cg;
    option.at_least = 2;
    cp: coverpoint p { bins z = {0}; bins o = {1}; }
  endgroup

  cg inst;

  initial begin
    inst = new;
    p = 0; inst.sample();
    p = 1; inst.sample();
    $display("one hit each: %0.2f", inst.get_inst_coverage());
    p = 0; inst.sample();
    $display("two hits of z: %0.2f", inst.get_inst_coverage());
    p = 1; inst.sample();
    $display("two hits each: %0.2f", inst.get_inst_coverage());
  end
endmodule
