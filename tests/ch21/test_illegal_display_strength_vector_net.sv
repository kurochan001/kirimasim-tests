/*
:name: test_illegal_display_strength_vector_net
:description: the argument of a %v format specification has to be a scalar net (IEEE 1800-2023 Section 21.2.1.4)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the %v specification of the last $display corresponds to bus, a 2-bit vector net
:expected_stderr_regex: test_illegal_display_strength_vector_net\.sv:30:
*/
// IEEE 1800-2023 §21.2.1.4: %v shows the strength of a scalar net, and the
// argument that corresponds to each %v specification shall be a scalar
// reference. The first $display gives the scalar net s to %v, which is
// legal. The last one gives the 2-bit vector net bus, which is the error.
// Icarus Verilog 13.0 accepts the design and prints a strength for each bit,
// and release 5.052 of the Verilator tool accepts it as well, so neither
// rejects it.

module test_illegal_display_strength_vector_net;
  wire s;
  wire [1:0] bus;
  assign s = 1'b1;
  assign bus = 2'b01;

  initial begin
    #1 $display("%v", s);
    $display("%v", bus);   // illegal: a vector net for %v
  end
endmodule
