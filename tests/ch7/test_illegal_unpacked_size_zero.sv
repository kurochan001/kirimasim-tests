/*
:name: test_illegal_unpacked_size_zero
:description: the single-number size of a fixed-size unpacked dimension has to be positive, and [size] means [0:size-1]; a size computed as zero from the bounds of [4] and [1] is illegal (IEEE 1800-2023 Section 7.4.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked dimension of bad is the single size SIZE, which is 0 and not positive
:expected_stderr_regex: test_illegal_unpacked_size_zero\.sv:37:
*/
// IEEE 1800-2023 §7.4.2: besides a range, a fixed-size unpacked dimension
// may be given by a single positive constant integer expression, the number
// of elements, as in C, and [size] then means the same as [0:size-1]. The
// legal arrays four [4] and one [1] use that form, and the legal design
// prints the element count and the left and right bounds of each
// (4 0 3 and 1 0 0).
// The size of bad is the localparam SIZE, computed from the bounds of four
// and one with array query functions, which a constant expression may call
// on a fixed-size array (20.7). SIZE is 0 exactly when [4] means [0:3] and
// [1] means [0:0], and 2 otherwise, so a tool rejects bad only when it both
// gives [size] the bounds [0:size-1] and requires the size to be positive.
// The legal design also prints SIZE (0).

module test_illegal_unpacked_size_zero;
  int four [4];
  int one [1];
  localparam int SIZE = ($left(four) == 0 && $right(four) == 3 &&
                         $left(one) == 0 && $right(one) == 0) ? 0 : 2;
  initial begin
    $display("%0d %0d %0d", $size(four), $left(four), $right(four));
    $display("%0d %0d %0d", $size(one), $left(one), $right(one));
    $display("%0d", SIZE);
  end
  int bad [SIZE];   // illegal: a size of zero
endmodule
