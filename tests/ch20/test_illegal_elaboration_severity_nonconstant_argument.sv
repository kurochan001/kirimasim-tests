/*
:name: test_illegal_elaboration_severity_nonconstant_argument
:description: the arguments of an elaboration severity task can only be a format string and constant expressions, including constant function calls, so a variable as an argument of an elaboration $info is an error (IEEE 1800-2023 Section 20.10.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.10.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the elaboration $info outside any procedure has the variable count as an argument, which is not a constant expression
:expected_stderr_regex: test_illegal_elaboration_severity_nonconstant_argument\.sv:37:
*/
// IEEE 1800-2023 §20.10.1: a severity task called outside procedural code is
// an elaboration severity task, and its list of arguments may only contain a
// format string and constant expressions, including constant function calls.
// Both $info calls are module items, so both are elaboration tasks. The
// first has a format string, a parameter and a call of the constant function
// twice (§13.4.3) with a constant argument, which is allowed. The second
// passes the variable count, which is not a constant expression, so it is the
// one error of the design: without that call, the design is legal. $info
// itself does not stop the elaboration (§20.10.1), so the only reason to
// reject the design is the argument.
// Icarus Verilog 13.0 reports the variable on that line, but it also
// rejects the call of the constant function on the line before, which
// §20.10.1 allows.

module test_illegal_elaboration_severity_nonconstant_argument;
  localparam int LIMIT = 4;
  int count = 3;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  $info("limit %0d, twice the limit %0d", LIMIT, twice(LIMIT));
  $info("count %0d", count);  // illegal: count is a variable
  initial $display("count=%0d", count);
endmodule
