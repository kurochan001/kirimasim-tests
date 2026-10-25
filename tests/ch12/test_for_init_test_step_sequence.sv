/*
:name: test_for_init_test_step_sequence
:description: A for loop runs its initialization once, tests its condition before every iteration, runs the step after each body and then tests again, exits on a false test, and repeats while the test is omitted (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_init_test_step_sequence.expected
*/
// IEEE 1800-2023 §12.7.1: a for loop a) runs its initialization once (when
// there is one); b) evaluates its condition, exits if it is false, and
// otherwise runs the body; c) runs its step (when there is one) and goes
// back to b). An omitted condition counts as true.
//
// The initialization, condition and step call functions that append I, T
// and S to a trace, and the body appends B, so the trace shows each step in
// order. The loops run two iterations, none (the first test is false), with
// no initialization and no step, and with no condition (left by break).

module test_for_init_test_step_sequence;
  string trace;
  int i;

  function automatic int init(int value);
    trace = {trace, "I"};
    return value;
  endfunction

  function automatic bit test(bit result);
    trace = {trace, "T"};
    return result;
  endfunction

  function automatic int step(int value);
    trace = {trace, "S"};
    return value + 1;
  endfunction

  initial begin
    trace = "";
    for (i = init(0); test(i < 2); i = step(i)) trace = {trace, "B"};
    $display("two iterations: %s i=%0d", trace, i);

    trace = "";
    for (i = init(5); test(i < 2); i = step(i)) trace = {trace, "B"};
    $display("no iteration:   %s i=%0d", trace, i);

    trace = "";
    i = 0;
    for (; test(i < 3); ) begin
      trace = {trace, "B"};
      i++;
    end
    $display("no init, no step: %s i=%0d", trace, i);

    trace = "";
    for (i = init(0); ; i = step(i)) begin
      trace = {trace, "B"};
      if (i == 2) break;
    end
    $display("no condition: %s i=%0d", trace, i);
  end
endmodule
