/*
:name: test_illegal_dynamic_new_initializer_other_element_type
:description: the initializer of a dynamic array new constructor has to be an array assignment compatible with the dynamic array; an array of byte elements is not, for an array of int (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.5.1 7.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initializer of new[2](narrow) is a dynamic array of byte, whose element type is not equivalent to int
:expected_stderr_regex: test_illegal_dynamic_new_initializer_other_element_type\.sv:33:
*/
// IEEE 1800-2023 §7.5.1: the optional parenthesized operand of new[] is an
// array with which the dynamic array is initialized, and it has to be
// assignment compatible with the dynamic array. §7.6: arrays are assignment
// compatible only if their element types are equivalent. The initializer
// wide, a dynamic array of int, is compatible with d, and the legal design
// prints the elements it copies, also when the new size is smaller than
// wide; narrow has byte elements.
// The 5.052 release accepts the initializer narrow and fails only when its
// generated C++ code is compiled, which does not count here.

module test_illegal_dynamic_new_initializer_other_element_type;
  int d [];
  int wide [] = '{4, 5, 6};
  byte narrow [] = '{1, 2};
  initial begin
    d = new[3](wide);
    $display("%0d %0d %0d %0d", d.size(), d[0], d[1], d[2]);
    d = new[2](wide);
    $display("%0d %0d %0d", d.size(), d[0], d[1]);
    d = new[2](narrow);   // illegal: byte elements for an int array
  end
endmodule
