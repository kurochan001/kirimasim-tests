/*
:name: test_vpi_legacy_partition_memory
:description: Use a legacy VPI application on a memory in a Verilog-1995 design partition
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_legacy_partition_memory.c
:expected_stdout: @test_vpi_legacy_partition_memory.expected
*/
`timescale 1ns/1ns
`begin_keywords "1364-1995"

module legacy_vpi_memory_partition;
  reg [7:0] samples [0:1];
  initial begin
    samples[0] = 8'd29;
    samples[1] = 8'd61;
  end
endmodule

module test_vpi_legacy_partition_memory;
  legacy_vpi_memory_partition legacy();

  initial begin
    #1;
    $display("hdl samples=%0d,%0d", legacy.samples[0], legacy.samples[1]);
    $finish;
  end
endmodule

`end_keywords
