/*
:name: test_illegal_nba_to_queue_element
:description: A nonblocking assignment cannot write an element of a queue, which is a dynamically sized array (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a nonblocking assignment writes an element of the queue q
:expected_stderr_regex: test_illegal_nba_to_queue_element\.sv:25:
*/
// IEEE 1800-2023 §10.4.2: it shall be illegal to make nonblocking
// assignments to elements of dynamically sized array variables; a queue is
// one (7.10). The blocking write of q[0] is legal, the nonblocking write of
// q[1] is not.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_nba_to_queue_element;
  int q[$] = '{0, 0};

  initial begin
    q[0] = 1;
    q[1] <= 2;   // illegal: nonblocking assignment to a queue element
  end
endmodule
