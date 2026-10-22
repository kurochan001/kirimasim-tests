/*
:name: test_program_output_after_module_nba_chain
:description: A program continuous output waits until a module NBA reaction to its input has completed (IEEE 1800-2023 Section 24.3.2)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.2 24.3.1 4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_output_after_module_nba_chain.expected
*/
// IEEE 1800-2023 24.3.2 24.3.1 4.5: The input update wakes a module NBA chain.
// The program output is computed only after that active region set settles, so
// its observer sees the completed state.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output. The 5.052 release does not reproduce the clause-derived output.

program complement_program(input wire [3:0] a, output wire [3:0] y);
  assign y = ~a;
endprogram
module test_program_output_after_module_nba_chain;
  bit [3:0] source;
  int module_state;
  wire [3:0] result;
  complement_program p(source, result);
  always @(source) if ($time > 0) module_state <= 1;
  always @(result) if ($time > 0)
    $display("source=%h output=%h module_state=%0d", source, result, module_state);
  initial begin #5 source <= 4'h3; #2 $finish; end
endmodule
