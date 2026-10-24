/*
:name: test_illegal_wildcard_array_find_index
:description: the index locator method find_index() is not allowed on an associative array with a wildcard index type (IEEE 1800-2023 Section 7.12.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.1 7.8.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the index locator method find_index() is called on the wildcard associative array w
:expected_stderr_regex: test_illegal_wildcard_array_find_index\.sv:36:
*/
// IEEE 1800-2023 §7.12.1: index locator methods return the indices of the
// matching elements, and associative arrays that specify a wildcard index
// type shall not be allowed. §7.8.1: such arrays shall not be used with an
// array manipulation method that returns an index value or an array of
// values. The last statement calls find_index() on w.
// The wildcard array w is written through indices of different sizes that
// have the same value, which name one entry, and read with num(), an
// element select and the reduction method sum(), all legal; the legal
// design prints 2 5 12.
// Icarus Verilog 13.0 does not support wildcard associative arrays and
// reports a syntax error on the declaration of w; it also reports one on
// the locator call, whose with clause it does not support, which does not
// count.

module test_illegal_wildcard_array_find_index;
  int w [*];
  int q [$];
  initial begin
    w[4'd3] = 4;
    w[32'd3] = w[3] + 1;
    w[1] = 7;
    $display("%0d %0d %0d", w.num(), w[3], w.sum());
    q = w.find_index with (item > 4);   // illegal: index locator on a wildcard array
  end
endmodule
