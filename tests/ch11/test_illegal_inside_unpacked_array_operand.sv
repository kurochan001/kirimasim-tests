/*
:name: test_illegal_inside_unpacked_array_operand
:description: the left-hand operand of the inside operator has to be singular, so it cannot be an unpacked array (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand operand of inside is the unpacked array arr
:expected_stderr_regex: test_illegal_inside_unpacked_array_operand\.sv:30:
*/
// IEEE 1800-2023 §11.4.13: the expression on the left-hand side of inside is
// any singular expression, while an unpacked array in the set on the right
// is traversed down to its singular elements. x inside {arr} and an element
// arr[1] on the left are legal; arr itself on the left is not.
// Icarus Verilog 13.0 does not support inside. The 5.052 release of Verilator
// reports the comparisons of arr with each value as type mismatches, not the
// operand that is not singular, so its error does not count.

module test_illegal_inside_unpacked_array_operand;
  int arr [3] = '{1, 2, 3};
  int x = 2;
  bit r1, r2, r3;

  initial begin
    r1 = x inside {arr};
    r2 = arr[1] inside {[1:2]};
    r3 = arr inside {1, 2, 3};   // illegal: an unpacked array on the left of inside
    $display("%b %b", r1, r2);
  end
endmodule
