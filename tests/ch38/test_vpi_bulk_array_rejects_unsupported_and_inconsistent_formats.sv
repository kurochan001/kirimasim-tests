/*
:name: test_vpi_bulk_array_rejects_unsupported_and_inconsistent_formats
:description: Bulk access rejects a string format and rejects a shortreal read from an integral array
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_bulk_array_invalid_options.c
:expected_stdout: @test_vpi_bulk_array_rejects_unsupported_and_inconsistent_formats.expected
:expected_stderr_regex: (?m)^string get vpi-error=1$\nshortreal get vpi-error=1$\nstring put vpi-error=1$
*/
`timescale 1ns/1ns
module test_vpi_bulk_array_rejects_unsupported_and_inconsistent_formats;
  int items[0:3] = '{11, 22, 33, 44};

  initial begin
    #1 $vt_bad_bulk_formats;
    $display("SV values=%0d/%0d/%0d/%0d", items[0], items[1], items[2], items[3]);
    $finish(0);
  end
endmodule
