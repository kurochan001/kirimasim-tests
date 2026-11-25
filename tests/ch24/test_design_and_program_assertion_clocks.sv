/*
:name: test_design_and_program_assertion_clocks
:description: Compare assertion sampling on a design clock and on a program clock
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_design_and_program_assertion_clocks.expected
*/
`timescale 1ns/1ns
program observations(input logic module_clock, input logic module_data);
  bit program_clock = 0;
  bit program_data = 0;

  design_clock: assert property (@(posedge module_clock) module_data == 0)
    $display("design clock t=%0d sampled=%b live=%b",
             $time, $sampled(module_data), module_data);
  else $display("design clock failed");

  program_clocked: assert property (@(posedge program_clock) program_data == 0)
    $display("program clock t=%0d sampled=%b live=%b",
             $time, $sampled(program_data), program_data);
  else $display("program clock failed");

  initial begin
    #3;
    if ($test$plusargs("observe_program_clock")) begin
      program_data = 1;
      program_clock = 1;
    end
    #1 $display("program complete t=%0d", $time);
    $finish(0);
  end
endprogram

module test_design_and_program_assertion_clocks;
  logic module_clock = 0;
  logic module_data = 0;
  observations observer(module_clock, module_data);
  initial begin
    #1 module_data = 1;
    module_clock = 1;
  end
endmodule
