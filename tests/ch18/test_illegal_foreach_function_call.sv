/*
:name: test_illegal_foreach_function_call
:description: A foreach constraint identifier shall not include a function call as an implicit variable declaration (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the foreach identifier geta()[i] contains a function call
:expected_stderr_regex: test_illegal_foreach_function_call\.sv:30:
// Icarus Verilog 13.0 does not support constraint declarations, so its
// error in the constraint block item list on that line does not count.
*/
// IEEE 1800-2023 §18.5.7.1: the argument of a foreach constraint is an array
// identifier with loop variables, and it shall be an error to include a
// function call as an implicit variable declaration in that identifier (see
// 13.4.1). The identifier geta()[i] calls a function and is illegal.

typedef int arr4_t[4];

class c_foreach_call;
  rand int a[4];

  function automatic arr4_t geta();
    return a;
  endfunction

  constraint c { foreach (geta()[i]) a[i] > 0; }   // illegal: function call
endclass

module test_illegal_foreach_function_call;
  c_foreach_call o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
