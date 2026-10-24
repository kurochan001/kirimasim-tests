/*
:name: test_illegal_call_empty_argument_without_default
:description: an empty placeholder cannot stand for an argument without a default (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call sum3(7, , 9) leaves the argument b, which has no default value, empty
:expected_stderr_regex: test_illegal_call_empty_argument_without_default\.sv:25:
*/
// IEEE 1800-2023 §13.5.3: an empty argument in a call is a placeholder for an
// argument with a default value; using one for an argument without a default
// is a compiler error. a and c of sum3 have defaults and b has none. The first
// call leaves a empty, which is legal; the second leaves b empty.

module test_illegal_call_empty_argument_without_default;
  function int sum3(input int a = 1, input int b, input int c = 3);
    return a + b + c;
  endfunction
  initial begin
    $display("%0d", sum3(, 5, 9));
    $display("%0d", sum3(7, , 9));   // illegal
  end
endmodule
