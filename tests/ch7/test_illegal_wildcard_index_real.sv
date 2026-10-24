/*
:name: test_illegal_wildcard_index_real
:description: the index of an associative array with a wildcard index type has to be integral; a real index is an error (IEEE 1800-2023 Section 7.8.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the wildcard associative array w is indexed by the real variable r
:expected_stderr_regex: test_illegal_wildcard_index_real\.sv:33:
*/
// IEEE 1800-2023 §7.8.1: an associative array with a wildcard index type
// may be indexed by any integral expression, and an index value that is not
// integral is illegal and results in an error. The last statement indexes
// w with a real variable.
// The wildcard array w is written through indices of different sizes that
// have the same value, which name one entry, and read with num(), an
// element select and the reduction method sum(), all legal; the legal
// design prints 2 5 12.
// Icarus Verilog 13.0 does not support wildcard associative arrays and
// reports a syntax error on the declaration of w.

module test_illegal_wildcard_index_real;
  int w [*];
  real r = 1.5;
  initial begin
    w[4'd3] = 4;
    w[32'd3] = w[3] + 1;
    w[1] = 7;
    $display("%0d %0d %0d", w.num(), w[3], w.sum());
    w[r] = 2;   // illegal: real index for a wildcard array
  end
endmodule
