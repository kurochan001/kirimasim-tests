/*
:name: test_illegal_nonblocking_to_dynamic_array_element
:description: An element of a dynamically sized array cannot be written by a nonblocking assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 7.5 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonblocking assignment writes da[1], an element of a dynamic array
:expected_stderr_regex: test_illegal_nonblocking_to_dynamic_array_element\.sv:25:
*/
// IEEE 1800-2023 §6.21: elements of dynamically sized array variables shall
// not be written with nonblocking assignments (§10.4.2). da is a dynamic
// array (§7.5); writing its element with a blocking assignment is legal,
// the nonblocking assignment is the error.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_nonblocking_to_dynamic_array_element;
  int da[];
  initial begin
    da = new[2];
    da[0] = 1;
    da[1] <= 2;    // illegal: nonblocking assignment to a dynamic array element
  end
endmodule
