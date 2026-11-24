/*
:name: test_virtual_interface_handle_rebinding_in_procedural_block_bodies
:description: Procedural reads through a virtual interface are legal in the bodies of always_comb, always_latch and always_ff
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 9.2.2.2.1 9.2.2.3 9.2.2.4 11.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_handle_rebinding_in_procedural_block_bodies.expected
*/
interface procedural_source;
  logic [3:0] data;
endinterface

module test_virtual_interface_handle_rebinding_in_procedural_block_bodies;
  procedural_source unused(), first(), second();
  virtual procedural_source selected = unused;
  bit open_latch, sample_clock;
  logic [3:0] combined, latched = 0, sampled = 0;

  always_comb combined = selected.data;
  always_latch if (open_latch) latched = selected.data;
  always_ff @(posedge sample_clock) sampled <= selected.data;

  initial begin
    first.data = 1;
    second.data = 7;
    #2;
    selected = first;
    open_latch = 1;
    #1 $display("first comb=%0d latch=%0d sample=%0d", combined, latched, sampled);
    sample_clock = 1;
    #1 $display("physical clock sampled=%0d", sampled);
    sample_clock = 0;
    open_latch = 0;
    #1 selected = second;
    #1 $display("second comb=%0d latch=%0d sample=%0d", combined, latched, sampled);
    open_latch = 1;
    sample_clock = 1;
    #1 $display("second enabled latch=%0d sample=%0d", latched, sampled);
  end
endmodule
