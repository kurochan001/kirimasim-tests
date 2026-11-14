/*
:name: test_illegal_dynamic_array_delete_result_as_value
:description: the dynamic array method delete() returns void, so a call of it cannot be used as a value; assigning its result is an error (IEEE 1800-2023 Section 7.5.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void method delete() of the dynamic array d is assigned to the variable n
:expected_stderr_regex: test_illegal_dynamic_array_delete_result_as_value\.sv:34:
*/
// IEEE 1800-2023 §7.5.3: the prototype of the dynamic array method delete()
// gives it the return type void. By §13.4.1 a call of a function can be used
// as an expression only when the function is not void; a call of a void
// function is a statement, and it has no value to use.
// The legal design calls d.delete() as a statement, which empties d, and
// prints the size of d before and after: 3 0. The last statement uses a call
// of delete() as the source of an assignment to the int variable n.
// Icarus Verilog 13.0 rejects the line with a message that delete is not
// a method of the array, the message it also gives for a name that is no
// method at all, so it does not show the rule and is not counted.
// The 5.054 release of Verilator accepts the line and fails only when it
// compiles the C++ code it generates, which does not count.

module test_illegal_dynamic_array_delete_result_as_value;
  int d [] = '{1, 2, 3};
  int n;
  initial begin
    n = d.size();
    d.delete();
    $display("%0d %0d", n, d.size());
    n = d.delete();   // illegal: delete() returns void
  end
endmodule
