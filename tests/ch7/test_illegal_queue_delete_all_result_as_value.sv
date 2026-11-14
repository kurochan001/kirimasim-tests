/*
:name: test_illegal_queue_delete_all_result_as_value
:description: the queue method delete() returns void also when it is called without an index, so a call of it cannot be used as a value; assigning its result is an error (IEEE 1800-2023 Section 7.10.2.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.10.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void method delete() of the queue q, called without an index, is assigned to the variable n
:expected_stderr_regex: test_illegal_queue_delete_all_result_as_value\.sv:37:
*/
// IEEE 1800-2023 §7.10.2.3: the prototype of the queue method delete() gives
// it the return type void, with or without its optional index argument. By
// §13.4.1 a call of a function can be used as an expression only when the
// function is not void; a call of a void function is a statement, and it has
// no value to use.
// The legal design calls q.delete() as a statement, which empties q, and
// prints the size of q before and after: 3 0. The last statement uses a call
// of delete() without an index as the source of an assignment to the int
// variable n. The form with an index is checked by
// test_illegal_queue_delete_index_result_as_value.
// Icarus Verilog 13.0 rejects the line with a message that delete is not
// a method of the array, the message it also gives for a name that is no
// method at all, so it does not show the rule and is not counted.
// The 5.054 release of Verilator accepts the line and fails only when it
// compiles the C++ code it generates, which does not count.

module test_illegal_queue_delete_all_result_as_value;
  int q [$] = '{10, 20, 30};
  int n;
  initial begin
    n = q.size();
    q.delete();
    $display("%0d %0d", n, q.size());
    n = q.delete();   // illegal: delete() returns void
  end
endmodule
