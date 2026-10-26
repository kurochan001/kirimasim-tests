/*
:name: test_illegal_bits_function_dynamic_return
:description: $bits encloses a function that returns a dynamically sized type (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $bits encloses the call of f, which returns the dynamic type int[]
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error))[^\n]*test_illegal_bits_function_dynamic_return\.sv:23:(?:\d+:)?[^\n]*(?i:(?:bits|size)[^\n]*(?:dynamic|variable)|dynamic[^\n]*(?:bits|size))
*/
// The value of $bits is determined without evaluating its expression,
// and it is an error to enclose a function that returns a dynamically
// sized data type. The function f returns int[].

module test_illegal_bits_function_dynamic_return;
  typedef int result_t[];
  function result_t f();
    return '{1, 2};
  endfunction
  localparam int W = $bits(f());   // illegal: dynamic return type
  initial $display(W);
endmodule
