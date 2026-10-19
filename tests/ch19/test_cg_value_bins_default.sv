/*
:name: test_cg_value_bins_default
:description: Coverage of a coverpoint with a single bin of several values, an array of bins and a default bin, which is not counted (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.5 19.11.1 19.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_value_bins_default.expected
*/
// IEEE 1800-2023 §19.5.1: bins lst = {0, [2:3]} is one bin covered by any of its
// values, and bins hi[] = {6, 7} makes one bin per value. §19.5: a default bin
// collects the values of no other bin, but coverage does not count it.
// §19.11.1: the coverage of a coverpoint with user-defined bins is the number
// of covered bins divided by the number of bins, here 3, and get_inst_coverage()
// (19.8) returns it as a percentage.

module test_cg_value_bins_default;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins lst = {0, [2:3]};
      bins hi[] = {6, 7};
      bins other = default;
    }
  endgroup

  cg inst;

  initial begin
    inst = new;
    a = 5; inst.sample();
    $display("after 5 (default bin only): %0.2f", inst.get_inst_coverage());
    a = 3; inst.sample();
    $display("after 3: %0.2f", inst.get_inst_coverage());
    a = 2; inst.sample();
    $display("after 2 (same bin): %0.2f", inst.get_inst_coverage());
    a = 7; inst.sample();
    $display("after 7: %0.2f", inst.get_inst_coverage());
    a = 6; inst.sample();
    $display("after 6: %0.2f", inst.get_inst_coverage());
  end
endmodule
