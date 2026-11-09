/*
:name: test_illegal_stacktrace_in_constant_expression
:description: $stacktrace is not one of the system functions that may be called in a constant expression, so it cannot give the value of a parameter (IEEE 1800-2023 Sections 11.2.1, 20.17.2)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.2.1 20.17.2 6.20.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the parameter TRACE is a call of $stacktrace, which is not a constant system function call
:expected_stderr_regex: test_illegal_stacktrace_in_constant_expression\.sv:31:
*/
// IEEE 1800-2023 §11.2.1: a constant expression may call only certain system
// functions, the pure ones whose value depends only on their arguments: the
// timescale, conversion, mathematical and bit vector functions, $sformatf,
// and the data and array query functions under their own conditions.
// $stacktrace is not among them; its value is the call stack at the moment of
// the call (§20.17.2), which does not exist at elaboration. A parameter value
// is a constant expression (§6.20.2). The parameter LABEL calls $sformatf with
// constant arguments, which is legal, and the legal design prints it (n=3) and
// the result of a run-time call of $stacktrace, which is a string that is not
// empty (1). The parameter TRACE calls $stacktrace.
// The 5.052 release of Verilator rejects the marked line because the call
// is not constant. Icarus Verilog 13.0 also rejects the legal parameter
// LABEL (it cannot convert the result of $sformatf to a string parameter),
// so its error on the marked line does not count.

module test_illegal_stacktrace_in_constant_expression;
  parameter string LABEL = $sformatf("n=%0d", 3);
  parameter string TRACE = $stacktrace;   // illegal: not a constant system function call
  string s;
  initial begin
    s = $stacktrace;
    $display("%s %0d", LABEL, s.len() > 0);
  end
endmodule
