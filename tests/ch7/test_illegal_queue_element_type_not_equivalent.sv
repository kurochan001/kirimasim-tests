/*
:name: test_illegal_queue_element_type_not_equivalent
:description: a queue is assignment compatible with another array only if the element types are equivalent; shortint elements cannot go to an int queue (IEEE 1800-2023 Section 7.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the dynamic array h of shortint elements is assigned to the queue q of int elements
:expected_stderr_regex: test_illegal_queue_element_type_not_equivalent\.sv:27:
*/
// IEEE 1800-2023 §7.6: a fixed-size, dynamic or queue array is assignment
// compatible with another only if their element types are equivalent. The
// dynamic array w of int elements is copied to the queue q, and the legal
// design prints the size and one element of q; the last assignment gives q
// the dynamic array h, whose shortint elements are not equivalent to int.

module test_illegal_queue_element_type_not_equivalent;
  int q [$];
  int w [] = '{4, 5, 6};
  shortint h [] = '{1, 2};
  initial begin
    q = w;
    $display("%0d %0d", q.size(), q[2]);
    q = h;   // illegal: shortint elements for an int queue
  end
endmodule
