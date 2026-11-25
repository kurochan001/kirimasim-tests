/*
:name: test_fsm_pragma_excludes_selects_in_state_concatenation
:description: Coverage recognizes whole signals in a state concatenation and a standalone part-select, and excludes selects inside a concatenation
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.4.3 40.4.2 40.4.6 40.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_fsm_pragma_excludes_selects_in_state_concatenation.c
:expected_stdout: @test_fsm_pragma_excludes_selects_in_state_concatenation.expected
*/
// The annotations are comments to the HDL. Observe which FSMs the
// coverage tool constructs. A part-select is valid on its own (40.4.2).
`timescale 1ns/1ns
module test_fsm_pragma_excludes_selects_in_state_concatenation;
  /* tool state_vector {hi, lo} whole_fsm enum modes */
  /* tool state_vector {wide[1], lo} bit_fsm enum modes */
  /* tool state_vector {wide[2:1], lo} part_fsm enum modes */
  /* tool state_vector wide[2:1] standalone_part_fsm enum modes */
  logic hi = 0, lo = 1;
  logic [3:0] wide = 4'b0100;
  parameter [2:0] /* tool enum modes */ S0 = 0, S1 = 1, S2 = 2;

  initial #1 $display("hdl whole=%b%b standalone=%b", hi, lo, wide[2:1]);
endmodule
