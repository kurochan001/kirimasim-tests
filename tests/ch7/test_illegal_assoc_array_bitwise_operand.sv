/*
:name: test_illegal_assoc_array_bitwise_operand
:description: an element has to be selected from an associative array before it is used in most expressions; a whole associative array as an operand of the bitwise operator & is an error (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the whole associative array m is an operand of the binary operator &
:expected_stderr_regex: test_illegal_assoc_array_bitwise_operand\.sv:38:
*/
// IEEE 1800-2023 §7.8: the elements of an associative array are unpacked, so
// apart from copying or comparing whole arrays, an element has to be selected
// from the array before it can be used in most expressions. §7.4.6 lists
// treatment as an integer in an expression among the operations of packed
// arrays that unpacked arrays do not have.
// The legal design copies m to c, compares the two arrays and applies & 12 to
// the element m[3], and prints the number of entries of c, the result of the
// comparison and the result of &: 2 1 4. The last statement uses the whole
// array m as an operand of the binary operator &.
// Icarus Verilog 13.0 does not support associative arrays with an index
// type and reports errors on their declarations, which do not count. The
// 5.054 release of Verilator rejects the line because the operand of & is
// not numeric.

module test_illegal_assoc_array_bitwise_operand;
  int m [int];
  int c [int];
  int r;
  initial begin
    m[3] = 6;
    m[8] = 1;
    c = m;
    r = m[3] & 12;
    $display("%0d %0d %0d", c.num(), c == m, r);
    r = m & 12;   // illegal: a whole associative array as an operand of &
  end
endmodule
