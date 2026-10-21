/*
:name: test_sched_deferred_action_arguments
:description: The action block of an observed deferred assertion runs in the Reactive region with its by-value arguments evaluated when the assertion was, while a const ref argument reads the value after the nonblocking update (IEEE 1800-2023 Section 4.4.2.7)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.7 16.4 4.4.2.4 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_deferred_action_arguments.expected
*/
// IEEE 1800-2023 §16.4: an observed deferred assertion (assert #0) evaluates
// its expression when it runs and schedules the subroutine call of its action
// block in the Reactive region (§4.4.2.7), after the NBA region (§4.4.2.4).
// Arguments passed by value are evaluated at the instant the expression is,
// while a const ref argument (§13.5.2) refers to the variable itself. The
// assertion fails with x = 0; the task called from the action block gets 0 by
// value and reads 5 through the reference, after the nonblocking update, and
// it runs after the display that follows the assertion.
// Icarus Verilog 13.0 supports neither deferred assertions nor const ref
// arguments. Verilator 5.052 runs the action block at once, before the display
// that follows the assertion (docs/simulator-differences.md).

module test_sched_deferred_action_arguments;
  int x = 0;

  task automatic report(int then_value, const ref int now_value);
    $display("by value: %0d, by reference: %0d", then_value, now_value);
  endtask

  initial begin
    x <= 5;
    a1: assert #0 (x == 5) else report(x, x);
    $display("after the assertion: x=%0d", x);
  end
endmodule
