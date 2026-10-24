/*
:name: test_illegal_wildcard_array_first
:description: the traversal method first() is not allowed on an associative array with a wildcard index type (IEEE 1800-2023 Section 7.9.4)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the traversal method first() is called on the wildcard associative array w
:expected_stderr_regex: test_illegal_wildcard_array_first\.sv:32:
*/
// IEEE 1800-2023 §7.9.4: first() takes an index of the appropriate type for
// the array, and associative arrays that specify a wildcard index type
// shall not be allowed. The last statement calls first() on w.
// The wildcard array w is written through indices of different sizes that
// have the same value, which name one entry, and read with num(), an
// element select and the reduction method sum(), all legal; the legal
// design prints 2 5 12.
// Icarus Verilog 13.0 does not support wildcard associative arrays and
// reports a syntax error on the declaration of w.

module test_illegal_wildcard_array_first;
  int w [*];
  int k = 3;
  initial begin
    w[4'd3] = 4;
    w[32'd3] = w[3] + 1;
    w[1] = 7;
    $display("%0d %0d %0d", w.num(), w[3], w.sum());
    void'(w.first(k));   // illegal: first() on a wildcard array
  end
endmodule
