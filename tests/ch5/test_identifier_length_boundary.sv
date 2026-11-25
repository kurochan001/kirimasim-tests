/*
:name: test_identifier_length_boundary
:description: Names differing only at their final character refer to distinct variables
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_length_boundary.expected
*/
// The Icarus qualification replaces the two names with longer identifiers.
module test_identifier_length_boundary;
  int length_probe_x = 17;
  int length_probe_y = 29;

  initial $display("distinct=%0d/%0d", length_probe_x, length_probe_y);
endmodule
