/*
:name: test_illegal_constant_function_calls_time
:description: a constant function can call only system functions allowed in constant expressions (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f, called in the initial value of the localparam P, calls $time
:expected_stderr_regex: test_illegal_constant_function_calls_time\.sv:(29|32):
*/
// IEEE 1800-2023 §13.4.3: a constant function shall only call system functions
// that are allowed in a constant expression (11.2.1): conversion, mathematical
// and bit vector functions and the like. h calls $clog2, which is one of them,
// so the call of h in the initial value of Q is legal; f calls $time, which is
// not.
// A function that breaks one of the constraints of a constant function is not
// one, and its call in the initial value of a localparam, which requires a
// constant expression (11.2.1), is then illegal; a tool can report the error at
// the call or at the line that breaks the constraint.

module test_illegal_constant_function_calls_time;
  function int h(input int a);
    return $clog2(a);
  endfunction
  function int f(input int a);
    return a + int'($time);
  endfunction
  localparam int Q = h(16);
  localparam int P = f(1);   // illegal
  initial $display("%0d %0d", P, Q);
endmodule
