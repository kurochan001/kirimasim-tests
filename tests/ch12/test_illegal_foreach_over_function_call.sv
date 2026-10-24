/*
:name: test_illegal_foreach_over_function_call
:description: the array of a foreach-loop cannot be given by a function call (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.7.3 13.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array of the foreach-loop is the function call make()
:expected_stderr_regex: test_illegal_foreach_over_function_call\.sv:31:
*/
// IEEE 1800-2023 §12.7.3: it shall be an error to include a function call as an
// implicit variable declaration in the array identifier of a foreach-loop. In
// make() the foreach-loop names the implicit variable make (13.4.1), which
// holds the result of the function and is legal; the loop in the initial block
// gives the array as the call make() instead.
// The grammar has no place for a call there, and Icarus Verilog 13.0 and
// the 5.052 release of Verilator reject the line with a syntax error.

module test_illegal_foreach_over_function_call;
  typedef int arr_t [3];
  function automatic arr_t make();
    foreach (make[i]) make[i] = i * 2;
  endfunction
  arr_t a;
  initial begin
    a = make();
    $display("%0d", a[2]);
    foreach (make()[i]) $display("%0d", i);   // illegal
  end
endmodule
