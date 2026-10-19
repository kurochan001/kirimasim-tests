/*
:name: test_cg_enum_auto_bins
:description: The automatic bins of an enum coverpoint are one per named value, not one per value of the base type (IEEE 1800-2023 Section 19.5.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.3 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_enum_auto_bins.expected
*/
// IEEE 1800-2023 §19.5.3: for an enum coverpoint without bins of its own, the
// number of automatic bins is the number of names of the enumeration. An enum
// of three names on a 3-bit base type has 3 bins, not 8, so each name sampled
// covers a third.
//
// Version 5.052 of Verilator makes 8 bins; Icarus Verilog 13.0 does not compile
// covergroups.

module test_cg_enum_auto_bins;
  typedef enum bit [2:0] {RED, GREEN, BLUE} color_t;
  color_t c;

  covergroup cg;
    coverpoint c;
  endgroup

  cg inst;

  initial begin
    inst = new;
    c = GREEN; inst.sample();
    $display("after GREEN: %0.2f", inst.get_inst_coverage());
    c = RED; inst.sample();
    c = BLUE; inst.sample();
    $display("after all three: %0.2f", inst.get_inst_coverage());
  end
endmodule
