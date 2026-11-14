/*
:name: test_illegal_constant_function_nonblocking_event_trigger
:description: a function that contains a nonblocking event trigger, which schedules the trigger after the function returns, cannot be called as a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, triggers its local event done with ->>
:expected_stderr_regex: test_illegal_constant_function_nonblocking_event_trigger\.sv:(37|46):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not contain a statement
// that directly schedules an event to execute after the function has
// returned. f triggers its local event done with the nonblocking trigger ->>
// (§15.5.1), which takes place after the call. §13.4.4 allows event triggers
// in a function, so the call of f in the initial procedure is legal; only its
// call in the initial value of P breaks the rule of constant functions. h
// computes the same value without the trigger, so the call of h in the
// initial value of Q is legal. Without P the design prints "3 5".
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the statement that breaks the constraint.
// Icarus Verilog 13.0 reports at the trigger that it does not know how to
// evaluate it at compile time, and the 5.054 release of Verilator reports
// that it has no evaluation for the trigger: both are limits of the tools
// rather than the rule, so they do not count.

module test_illegal_constant_function_nonblocking_event_trigger;
  function int h(input int a);
    return a + 1;
  endfunction
  function int f(input int a);
    event done;
    ->> done;
    return a + 1;
  endfunction
  localparam int Q = h(2);
  int r;
  initial begin
    r = f(4);
    $display("%0d %0d", Q, r);
  end
  localparam int P = f(1);   // illegal
endmodule
