/*
:name: test_illegal_wildcard_array_find
:description: an array manipulation method that returns an array of values, such as find(), is not allowed on an associative array with a wildcard index type (IEEE 1800-2023 Section 7.8.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.1 7.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the locator method find(), which returns an array of values, is called on the wildcard associative array w
:expected_stderr_regex: test_illegal_wildcard_array_find\.sv:37:
*/
// IEEE 1800-2023 §7.8.1: an associative array that specifies a wildcard
// index type shall not be used with an array manipulation method (7.12)
// that returns an index value or an array of values. find() returns a
// queue of the matching elements (7.12.1). The last statement calls find()
// on w.
// The wildcard array w is written through indices of different sizes that
// have the same value, which name one entry, and read with num(), an
// element select and the reduction method sum(), all legal; the legal
// design prints 2 5 12.
// Icarus Verilog 13.0 does not support wildcard associative arrays and
// reports a syntax error on the declaration of w; it also reports one on
// the locator call, whose with clause it does not support, which does not
// count.
// The 5.052 release accepts find() on a wildcard array.

module test_illegal_wildcard_array_find;
  int w [*];
  int q [$];
  initial begin
    w[4'd3] = 4;
    w[32'd3] = w[3] + 1;
    w[1] = 7;
    $display("%0d %0d %0d", w.num(), w[3], w.sum());
    q = w.find with (item > 4);   // illegal: find() on a wildcard array
  end
endmodule
