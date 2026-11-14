/*
:name: test_illegal_queue_delete_index_result_as_value
:description: the queue method delete() returns void also when it is given an index, so a call of it cannot be used as a value; assigning its result is an error (IEEE 1800-2023 Section 7.10.2.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.10.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void method delete() of the queue q, called with an index, is assigned to the variable n
:expected_stderr_regex: test_illegal_queue_delete_index_result_as_value\.sv:34:
*/
// IEEE 1800-2023 §7.10.2.3: the prototype of the queue method delete() gives
// it the return type void, with or without its optional index argument. By
// §13.4.1 a call of a function can be used as an expression only when the
// function is not void; a call of a void function is a statement, and it has
// no value to use.
// The legal design calls q.delete(1) as a statement and prints the size and
// the elements of q: 2 10 30. The last statement uses a call of delete() with
// an index as the source of an assignment to the int variable n. The form
// without an index is checked by test_illegal_queue_delete_all_result_as_value.
// Icarus Verilog 13.0 rejects the line with a message that delete is not
// a method of the array, the message it also gives for a name that is no
// method at all, so it does not show the rule and is not counted.
// The 5.054 release of Verilator accepts the design.

module test_illegal_queue_delete_index_result_as_value;
  int q [$] = '{10, 20, 30};
  int n;
  initial begin
    q.delete(1);
    $display("%0d %0d %0d", q.size(), q[0], q[1]);
    n = q.delete(0);   // illegal: delete() returns void
  end
endmodule
