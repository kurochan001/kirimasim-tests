/*
:name: test_illegal_compare_arrays_of_different_element_types
:description: the operands of an equality comparison of aggregate expressions have to be of equivalent types (IEEE 1800-2023 Section 11.2.2)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array ia of int is compared with the unpacked array ba of byte, which is not an equivalent type
:expected_stderr_regex: test_illegal_compare_arrays_of_different_element_types\.sv:32:
*/
// IEEE 1800-2023 §11.2.2: aggregate expressions can be compared with the
// equality and inequality operators, and the two operands shall then be of
// equivalent types (6.22.2). ia == ib and ia != ic, arrays of three int
// (ic with other bounds of the same size), are legal; ia == ba compares
// an array of int with an array of byte.
// Icarus Verilog 13.0 also rejects the legal comparisons of whole int arrays,
// so its error does not count.

module test_illegal_compare_arrays_of_different_element_types;
  int ia [3] = '{1, 2, 3};
  int ib [3] = '{1, 2, 3};
  int ic [1:3] = '{1, 2, 4};
  byte ba [3] = '{1, 2, 3};
  bit r1, r2, r3;

  initial begin
    r1 = (ia == ib);
    r2 = (ia != ic);
    r3 = (ia == ba);   // illegal: int[3] and byte[3] are not equivalent
    $display("%b %b", r1, r2);
  end
endmodule
