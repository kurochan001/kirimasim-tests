/*
:name: test_illegal_unpacked_size_negative
:description: the single-number size of a fixed-size unpacked dimension has to be positive; a negative size is illegal (IEEE 1800-2023 Section 7.4.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked dimension of bad is the single size -2, which is not positive
:expected_stderr_regex: test_illegal_unpacked_size_negative\.sv:29:
*/
// IEEE 1800-2023 §7.4.2: besides a range, a fixed-size unpacked dimension
// may be given by a single positive constant integer expression, the number
// of elements, as in C, and [size] then means the same as [0:size-1]. The
// legal arrays four [4] and one [1] use that form, and the legal design
// prints the element count and the left and right bounds of each
// (4 0 3 and 1 0 0).
// The size of bad is the negative constant -2.

module test_illegal_unpacked_size_negative;
  int four [4];
  int one [1];
  initial begin
    $display("%0d %0d %0d", $size(four), $left(four), $right(four));
    $display("%0d %0d %0d", $size(one), $left(one), $right(one));
  end
  int bad [-2];   // illegal: a negative size
endmodule
