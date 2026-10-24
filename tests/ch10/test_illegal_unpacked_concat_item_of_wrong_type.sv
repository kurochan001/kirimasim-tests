/*
:name: test_illegal_unpacked_concat_item_of_wrong_type
:description: an item of an unpacked array concatenation has to be assignment compatible with the element type of the target, or be an array of such elements, or be null for class elements (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class handle h is an item of an unpacked array concatenation whose target has int elements
:expected_stderr_regex: test_illegal_unpacked_concat_item_of_wrong_type\.sv:37:
*/
// IEEE 1800-2023 §10.10: an item whose self-determined type is assignment
// compatible with the element type of the target is one element, an item
// that is an unpacked array of such elements gives its elements, and the
// literal null is allowed for elements of class type; an item of any other
// type is illegal. The real r for an int element, the array a2, and null for
// the class array hs are legal; the class handle h for an int element is not.
// Icarus Verilog 13.0 cannot elaborate the legal unpacked array
// concatenations either, so its error does not count.

class obj_c;
endclass

module test_illegal_unpacked_concat_item_of_wrong_type;
  int a2 [2] = '{1, 2};
  int a4 [4];
  obj_c hs [2];
  obj_c h = new;
  real r = 3.0;
  int b = 4;

  initial begin
    a4 = {a2, r, b};
    hs = {null, h};
    a4 = {a2, h, b};   // illegal: a class handle is not compatible with int
    $display("%p", a4);
  end
endmodule
