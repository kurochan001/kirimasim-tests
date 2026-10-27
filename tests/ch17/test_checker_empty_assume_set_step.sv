/*
:name: test_checker_empty_assume_set_step
:description: A checker with an empty assume set has an implicit event in every time step, and its active free variable is updated at most once and then stays constant to the end of that time step (IEEE 1800-2023 Section 17.7.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_empty_assume_set_step.expected
*/
// IEEE 1800-2023 17.7.2: an empty assume set is considered to have an implicit
// assume set clock event in every time step before the Observed region. Active
// free variables of such a checker are implicitly clocked and may be updated
// with unconstrained random values at every time step.  Once updated, the
// variables stay constant until the end of the time step.  The checker below
// has no assume statement and never assigns z, so z is an active free variable
// with an empty assume set.  The module watches zout, which follows z through a
// continuous assignment, and counts any second change at the same nonzero
// simulation time: such a change would mean that z was randomized more than
// once in the same time step.  The initial value and any change at time 0 are
// ignored, because the initialization and the first implicit event share that
// step.  The expected count is zero; whether z changes in a step at all is not
// fixed, because the implicit update is permitted, not required.
// Icarus Verilog 13.0 has no checkers and Verilator 5.052 rejects rand
// variables in checkers, so the expected output follows the clauses alone.

`timescale 1ns/1ns

checker empty_assume(output bit [7:0] zout);
  rand bit [7:0] z;   // active: no assignment and no assume statement
  assign zout = z;
endchecker : empty_assume

module test_checker_empty_assume_set_step;
  logic clk = 1'b0;
  bit [7:0] zout;
  int same_step = 0;
  bit seen = 1'b0;
  time last_t = 0;

  empty_assume u_empty(.zout(zout));

  always @(zout) begin
    if ($time != 0) begin
      if (seen && $time == last_t)
        same_step = same_step + 1;
      last_t = $time;
      seen = 1'b1;
    end
  end

  always #5 clk = ~clk;

  initial begin
    #45 $display("same_step_updates=%0d", same_step);
    $finish;
  end
endmodule
