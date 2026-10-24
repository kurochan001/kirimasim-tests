/*
:name: test_illegal_wildcard_array_foreach
:description: an associative array with a wildcard index type cannot be used in a foreach loop (IEEE 1800-2023 Section 7.8.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.1 12.7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a foreach loop iterates over the wildcard associative array w
:expected_stderr_regex: test_illegal_wildcard_array_foreach\.sv:31:
*/
// IEEE 1800-2023 §7.8.1: an associative array that specifies a wildcard
// index type shall not be used in a foreach loop (12.7.3). The last
// statement is a foreach loop over w.
// The wildcard array w is written through indices of different sizes that
// have the same value, which name one entry, and read with num(), an
// element select and the reduction method sum(), all legal; the legal
// design prints 2 5 12.
// Icarus Verilog 13.0 does not support wildcard associative arrays and
// reports a syntax error on the declaration of w.

module test_illegal_wildcard_array_foreach;
  int w [*];
  initial begin
    w[4'd3] = 4;
    w[32'd3] = w[3] + 1;
    w[1] = 7;
    $display("%0d %0d %0d", w.num(), w[3], w.sum());
    foreach (w[i]) $display("%0d", w[i]);   // illegal: foreach over a wildcard array
  end
endmodule
