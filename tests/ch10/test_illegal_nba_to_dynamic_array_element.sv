/*
:name: test_illegal_nba_to_dynamic_array_element
:description: A nonblocking assignment cannot write an element of a dynamic array (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a nonblocking assignment writes an element of the dynamic array d
:expected_stderr_regex: test_illegal_nba_to_dynamic_array_element\.sv:26:
*/
// IEEE 1800-2023 §10.4.2: it shall be illegal to make nonblocking
// assignments to automatic variables or to elements of dynamically sized
// array variables. d is a dynamic array; the blocking write of d[0] is
// legal, the nonblocking write of d[1] is not.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_nba_to_dynamic_array_element;
  int d[];

  initial begin
    d = new[2];
    d[0] = 1;
    d[1] <= 2;   // illegal: nonblocking assignment to a dynamic array element
  end
endmodule
