/*
:name: test_illegal_sort_result_as_value
:description: the array ordering method sort() returns void, so a call of it cannot be used as a value; assigning its result to a queue is an error (IEEE 1800-2023 Section 7.12.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void ordering method sort() of the queue q is assigned to the queue r
:expected_stderr_regex: test_illegal_sort_result_as_value\.sv:35:
*/
// IEEE 1800-2023 §7.12.2: the prototype of the array ordering methods
// reverse(), sort(), rsort() and shuffle() gives them the return type void;
// they reorder the array in place. By §13.4.1 a call of a function can be
// used as an expression only when the function is not void; a call of a void
// function is a statement, and it has no value to use.
// The legal design calls q.sort() as a statement and prints the elements of
// q: 1 2 3. The last statement uses a call of sort() as the source of an
// assignment to the queue r, which has the type of q, so the call is
// rejected only because it has no value, not because a value would have the
// wrong type.
// Icarus Verilog 13.0 does not support the ordering methods and reports
// errors on their calls, which do not count.
// The 5.054 release of Verilator accepts the line and fails only when it
// compiles the C++ code it generates, which does not count.

module test_illegal_sort_result_as_value;
  int q [$] = '{3, 1, 2};
  int r [$];
  initial begin
    q.sort();
    $display("%0d %0d %0d", q[0], q[1], q[2]);
    r = q.sort();   // illegal: sort() returns void
  end
endmodule
