/*
:name: test_per_file_timescale_does_not_override_next_unit_timeunit
:description: A timescale stays in its file unit while a later file uses its declared time unit
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.1 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_per_file_timescale_does_not_override_next_unit_timeunit.expected
:files: isolated_timescale_provider.sv
:args: --compilation-unit=per-file
*/
timeunit 1ns/1ps;

module per_unit_delay(output bit done);
  initial #1.24 done = 1;
endmodule

module test_per_file_timescale_does_not_override_next_unit_timeunit;
  timeunit 1ps/1ps;
  wire first, second;
  directive_delay direct_delay(first);
  per_unit_delay other_delay(second);

  initial begin
    @(posedge second);
    $display("second=%0d ps", $time);
    @(posedge first);
    $display("first=%0d ps", $time);
  end
endmodule
