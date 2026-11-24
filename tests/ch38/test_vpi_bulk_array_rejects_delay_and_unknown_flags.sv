/*
:name: test_vpi_bulk_array_rejects_delay_and_unknown_flags
:description: A bulk array write accepts the one-value flag and rejects scheduling flags and an unknown flag
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_bulk_array_invalid_options.c
:expected_stdout: @test_vpi_bulk_array_rejects_delay_and_unknown_flags.expected
:expected_stderr_regex: (?m)^inertial vpi-error=1$\ntransport vpi-error=1$\npure transport vpi-error=1$\nunknown flag vpi-error=1$
*/
`timescale 1ns/1ns
module test_vpi_bulk_array_rejects_delay_and_unknown_flags;
  int items[0:3] = '{11, 22, 33, 44};

  initial begin
    #1 $vt_bad_bulk_flags;
    $display("now values=%0d/%0d/%0d/%0d", items[0], items[1], items[2], items[3]);
    #5 $display("later values=%0d/%0d/%0d/%0d", items[0], items[1], items[2], items[3]);
    $finish(0);
  end
endmodule
