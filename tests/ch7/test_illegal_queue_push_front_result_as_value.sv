/*
:name: test_illegal_queue_push_front_result_as_value
:description: the queue method push_front() returns void, so a call of it cannot be used as a value; assigning its result is an error (IEEE 1800-2023 Section 7.10.2.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.10.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the result of the void method push_front() of the queue q is assigned to the variable n
:expected_stderr_regex: test_illegal_queue_push_front_result_as_value\.sv:33:
*/
// IEEE 1800-2023 §7.10.2.6: the prototype of the queue method push_front()
// gives it the return type void. By §13.4.1 a call of a function can be used
// as an expression only when the function is not void; a call of a void
// function is a statement, and it has no value to use.
// The legal design calls q.push_front(10) as a statement and prints the size
// and the elements of q: 3 10 20 30. The last statement uses a call of
// push_front() as the source of an assignment to the int variable n.
// Icarus Verilog 13.0 rejects the line with a message that push_front is not
// a method of the array, the message it also gives for a name that is no
// method at all, so it does not show the rule and is not counted.
// The 5.054 release of Verilator accepts the line and fails only when it
// compiles the C++ code it generates, which does not count.

module test_illegal_queue_push_front_result_as_value;
  int q [$] = '{20, 30};
  int n;
  initial begin
    q.push_front(10);
    $display("%0d %0d %0d %0d", q.size(), q[0], q[1], q[2]);
    n = q.push_front(5);   // illegal: push_front() returns void
  end
endmodule
