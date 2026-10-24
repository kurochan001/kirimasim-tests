/*
:name: test_illegal_array_pattern_duplicate_index_key
:description: the same index cannot be given twice as a key in one array assignment pattern (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array assignment pattern gives the index key 0 twice
:expected_stderr_regex: test_illegal_array_pattern_duplicate_index_key\.sv:29:
*/
// IEEE 1800-2023 §10.9.1: an index:value item sets the element with that
// index, and it shall be an error to give the same index more than once in a
// single array pattern. The first two patterns give each index at most once,
// in any order and with a default for the rest, which is legal; the third
// gives the index 0 twice.
// Icarus Verilog 13.0 gives syntax errors also on the legal patterns with keys,
// so its error does not count.

module test_illegal_array_pattern_duplicate_index_key;
  int a4 [4];
  int b4 [4];

  initial begin
    a4 = '{0:1, 1:2, default:0};
    b4 = '{3:7, 0:1, 1:2, 2:3};
    a4 = '{0:1, 2:5, 0:3, default:0};   // illegal: index 0 is given twice
    $display("%p %p", a4, b4);
  end
endmodule
