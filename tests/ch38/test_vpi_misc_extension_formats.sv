/*
:name: test_vpi_misc_extension_formats
:description: Distinct VPI extension formats select bit-plane and state-count payloads for four-state values
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_vpi_misc_extension_formats.expected
:vpi_c: @vpi_misc_formats/probe.c
:files: vpi_misc_formats/formats.h vpi_misc_formats/provider.c vpi_misc_formats/reference.expected
*/
`timescale 1ns/1ns

module test_vpi_misc_extension_formats;
  logic [39:0] wide;
  logic [9:0] narrow;

  initial begin
    wide = 40'b10xz_0110_xz01_0011_1100_0zx1_0101_0011_z0x1_1010;
    narrow = 10'b01_xz10_01zx;
    #1 $finish(0);
  end
endmodule
