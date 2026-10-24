/*
:name: test_illegal_unpacked_concat_count_differs_from_fixed_target
:description: the number of elements of an unpacked array concatenation has to equal the size of a fixed-size target array (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array concatenation {a2, b, c} gives four elements for the fixed-size array a3 of three
:expected_stderr_regex: test_illegal_unpacked_concat_count_differs_from_fixed_target\.sv:32:
*/
// IEEE 1800-2023 §10.10: an item of an unpacked array concatenation is one
// element or, for an array item, as many elements as it has; it shall be an
// error if the size of the result differs from the number of elements of a
// fixed-size target. {a2, b} and {b, c, b} give three elements for a3, and a
// queue takes any number, which is legal; {a2, b, c} gives four.
// Icarus Verilog 13.0 cannot elaborate the legal unpacked array
// concatenations either, so its error does not count.

module test_illegal_unpacked_concat_count_differs_from_fixed_target;
  int a2 [2] = '{1, 2};
  int a3 [3];
  int q [$];
  int b = 7, c = 8;

  initial begin
    a3 = {a2, b};
    a3 = {b, c, b};
    q = {a2, b, c};
    a3 = {a2, b, c};   // illegal: four elements for a target of three
    $display("%p %p", a3, q);
  end
endmodule
