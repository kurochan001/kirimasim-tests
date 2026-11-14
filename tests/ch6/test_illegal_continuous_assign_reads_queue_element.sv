/*
:name: test_illegal_continuous_assign_reads_queue_element
:description: A continuous assignment cannot reference an element of a queue, a dynamic variable, since such references are limited to procedural blocks (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w reads q[0], an element of the queue q, outside a procedural block
:expected_stderr_regex: test_illegal_continuous_assign_reads_queue_element\.sv:26:
*/
// IEEE 1800-2023 §6.21: references to elements of dynamic variables shall be
// limited to procedural blocks. A queue is a dynamically sized array whose
// elements come and go at run time (7.10). A continuous assignment is not a
// procedural block, so the assignment to w on the marked line, which reads the
// element q[0], is illegal, although the initial procedure gives the queue an
// element. Without the continuous assignment, the design is legal.
// Oracle check: the compiler of Icarus Verilog 13.0 crashes on the design, and
// the 5.054 release of Verilator accepts it.

module test_illegal_continuous_assign_reads_queue_element;
  int q[$];
  wire [31:0] w;
  assign w = q[0];    // illegal: queue element outside a procedure
  initial q.push_back(7);
endmodule
