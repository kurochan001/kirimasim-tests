/*
:name: test_normative_dated_vpi_edition
:description: Observe the VPI memory view specified by the dated IEEE 1364-1995 reference
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 2 L.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_normative_dated_vpi_edition.c
:files: ../ch6/normative_reference_editions/publishers.json ../ch6/normative_reference_editions/dated.expected
:expected_stdout: @test_normative_dated_vpi_edition.expected
*/
`timescale 1ns/1ns
module test_normative_dated_vpi_edition;
  reg [7:0] samples [2:3];
  initial begin
    samples[3] = 8'h65;
    #1 $vt_normative_edition;
    $finish(0);
  end
endmodule
