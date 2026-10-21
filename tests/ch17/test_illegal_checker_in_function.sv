/*
:name: test_illegal_checker_in_function
:description: A checker cannot be instantiated in a function, which is procedural code (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a checker is instantiated in a function, which is a procedural block
:expected_stderr_regex: test_illegal_checker_in_function\.sv:26:
*/
// IEEE 1800-2023 §17.3: a checker can be instantiated in a module,
// interface, program, checker or generate block, but not in procedural code.
// A function body is procedural code, so the instance at line 26 is illegal.
// The 5.052 release reports a syntax error there; Icarus Verilog 13.0 does
// not support checkers at all, so its error falls on the declaration.

checker chk_one(input logic a);
  assert property (@(posedge a) 1);
endchecker

module test_illegal_checker_in_function;
  function automatic void f();
    chk_one c(1'b0);
  endfunction

  initial f();
endmodule
