/*
:name: test_program_assertion_clocked_by_program_variable
:description: A concurrent assertion in a program clocked by a program variable that the program changes in the Reactive region is still evaluated in the same time step, with the values sampled in the Preponed region (IEEE 1800-2023 Section 24.3.1)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.1 16.5.1 16.9.3 4.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_assertion_clocked_by_program_variable.expected
*/
// IEEE 1800-2023 §24.3.1: a concurrent assertion in a program keeps the
// scheduling it has in design code: its values are sampled in the Preponed
// region and it is evaluated in the Observed region. When its clock is a
// program object, which changes in the reactive region set, the scheduler
// goes back around the loop of Figure 4-1 (4.5) to the Observed region of the
// same time step to evaluate it. §16.5.1 and §16.9.3: the sampled value of a
// variable is its value in the Preponed region of the time step, also when
// $sampled is called in an action block.
// pclk and a are variables of the program. Its initial procedure, which runs
// in the Reactive region, sets a and raises pclk in the same step:
// - at 5 it sets a = 1, so the assertion a == 0 sees the sampled 0 and passes;
// - at 15 it sets a = 0, so the assertion sees the sampled 1 and fails.
// Each action block prints the time, the sampled value and the value of a at
// that point. Both ticks are evaluated at the time of the clock change; an
// implementation that sampled a after the program's change would fail at 5
// and pass at 15. The initial procedure ends at 16, which ends the run.
// Icarus Verilog 13.0 does not support concurrent assertions.

`timescale 1ns/1ns

program test_program_assertion_clocked_by_program_variable;
  bit pclk;
  int a;

  a_prog_clock: assert property (@(posedge pclk) a == 0)
    $display("t=%0t pass: sampled a=%0d, a=%0d", $time, $sampled(a), a);
  else
    $display("t=%0t fail: sampled a=%0d, a=%0d", $time, $sampled(a), a);

  initial begin
    #5 a = 1;
    pclk = 1;
    #5 pclk = 0;
    #5 a = 0;
    pclk = 1;
    #1;
  end
endprogram
