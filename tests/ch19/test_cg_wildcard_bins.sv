/*
:name: test_cg_wildcard_bins
:description: In a wildcard bin, ? bits of the values match any bit of the sampled value (IEEE 1800-2023 Section 19.5.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.4 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_wildcard_bins.expected
*/
// IEEE 1800-2023 §19.5.4: in wildcard bins, an x, z or ? bit of a value stands
// for either 0 or 1, so wildcard bins hi = {4'b1??0} is covered by any 4-bit
// value whose top bit is 1 and whose bottom bit is 0, and not by others.

module test_cg_wildcard_bins;
  bit [3:0] w;

  covergroup cg;
    cp: coverpoint w {
      wildcard bins hi = {4'b1??0};
      bins lo = {[0:3]};
    }
  endgroup

  cg inst;

  initial begin
    inst = new;
    w = 4'b1001; inst.sample();
    $display("after 1001 (bottom bit is 1): %0.2f", inst.get_inst_coverage());
    w = 4'b0110; inst.sample();
    $display("after 0110 (top bit is 0): %0.2f", inst.get_inst_coverage());
    w = 4'b1110; inst.sample();
    $display("after 1110: %0.2f", inst.get_inst_coverage());
    w = 4'b0010; inst.sample();
    $display("after 0010: %0.2f", inst.get_inst_coverage());
  end
endmodule
