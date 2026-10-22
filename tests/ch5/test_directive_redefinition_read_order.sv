/*
:name: test_directive_redefinition_read_order
:description: A macro redefinition affects later uses but not declarations already read (IEEE 1800-2023 Section 5.6.4)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.4 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_directive_redefinition_read_order.expected
*/
// IEEE 1800-2023 5.6.4 22.5.1: Local parameters retain values expanded before a
// later redefinition; undef removes the last definition.

`define DEPTH_VALUE 13
module test_directive_redefinition_read_order;
  localparam int A = `DEPTH_VALUE;
`undef DEPTH_VALUE
`define DEPTH_VALUE 27
  localparam int B = `DEPTH_VALUE;
`undef DEPTH_VALUE
  initial $display("expanded=%0d,%0d", A, B);
endmodule
