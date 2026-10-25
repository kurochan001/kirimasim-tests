/*
:name: test_display_finish
:description: $display and $write of string literals in an initial block, and $finish ending the run before the next statement
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1 20.2 9.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_display_finish.expected
*/
// From kirimasim tests/suite/smoke/display_finish.sv, 2026-10-25.
// Its expectation is checked against the clauses below.
// $display ends the line and $write does not (21.2.1); %% prints a single %.
// $finish ends the simulation, so the last $display never runs (20.2).
// Verilator 5.052 (--binary) still prints "never": it ends the run only
// after the process finishes its time step.
module top;
  initial begin
    $display("hello");
    $write("a");
    $display("b 100%%");
    $finish;
    $display("never");
  end
endmodule
