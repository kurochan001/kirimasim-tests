/*
:name: test_vpi_iterator_released_on_terminal_scan
:description: An abandoned iterator and a drained iterator release independently
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.40 38.38 37.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_iterator_released_on_terminal_scan
:vpi_c: @test_vpi_iterator_released_on_terminal_scan.c
:expected_stdout: @test_vpi_iterator_released_on_terminal_scan.expected
*/
`timescale 1ns/1ns
module iterator_release_child;
endmodule

module test_vpi_iterator_released_on_terminal_scan;
  iterator_release_child first(), second(), third();
  initial #1 $finish(0);
endmodule
