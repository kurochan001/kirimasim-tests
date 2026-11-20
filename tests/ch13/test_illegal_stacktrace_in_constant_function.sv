/*
:name: test_illegal_stacktrace_in_constant_function
:description: A function that calls $stacktrace is not a constant function, so calling it to give the value of a localparam is an error, while calling it at run time is legal (IEEE 1800-2023 Sections 13.4.3, 20.17.2, 11.2.1)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3 20.17.2 11.2.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam BAD calls traced(), which calls $stacktrace, a system function that is not allowed in a constant expression, so the call is not a constant function call
:expected_stderr_regex: test_illegal_stacktrace_in_constant_function\.sv:(39|34):
*/
// IEEE 1800-2023 §13.4.3: a function called in a constant expression has to
// be a constant function, which shall only call the system functions allowed
// in a constant expression (§11.2.1). $stacktrace is not one of them: its
// value is the call stack at the time of the call (§20.17.2). doubled() is a
// constant function and gives OK = 6. traced() keeps $stacktrace in a local
// string and returns its argument; called at run time it is an ordinary
// function and returns 5. The localparam BAD calls traced() in a constant
// expression. A tool can report the call or the $stacktrace in the function.
// With doubled(1) in the marked line the design is legal and prints 6 5.
// The 5.054 release of Verilator rejects the marked line because the call is
// not constant. Icarus Verilog 13.0 stops on an internal assertion when it
// compiles the legal design, so its errors here do not count.

module test_illegal_stacktrace_in_constant_function;
  function automatic int doubled(int n);
    return 2 * n;
  endfunction

  function automatic int traced(int n);
    string s;
    s = $stacktrace;   // (or reported here)
    return n;
  endfunction

  localparam int OK = doubled(3);
  localparam int BAD = traced(1);   // illegal: traced() is not a constant function

  initial $display("%0d %0d", OK, traced(5));
endmodule
