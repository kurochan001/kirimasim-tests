/*
:name: test_illegal_unpacked_size_real
:description: the single-number size of a fixed-size unpacked dimension has to be an integer; a real parameter is illegal (IEEE 1800-2023 Section 7.4.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked dimension of bad is the single size R, a real parameter whose value is not an integer
:expected_stderr_regex: test_illegal_unpacked_size_real\.sv:34:
*/
// IEEE 1800-2023 §7.4.2: besides a range, a fixed-size unpacked dimension
// may be given by a single positive constant integer expression, the number
// of elements, as in C, and [size] then means the same as [0:size-1]. The
// legal arrays four [4] and one [1] use that form, and the legal design
// prints the element count and the left and right bounds of each
// (4 0 3 and 1 0 0).
// The size of bad is the real parameter R, a positive constant whose value
// 2.5 is not an integer.
// Icarus Verilog 13.0 accepts the design. The 5.054 release of Verilator
// rejects the line with a message about the width of a value rather than
// the type of the size, which is not counted.

module test_illegal_unpacked_size_real;
  int four [4];
  int one [1];
  parameter real R = 2.5;
  initial begin
    $display("%0d %0d %0d", $size(four), $left(four), $right(four));
    $display("%0d %0d %0d", $size(one), $left(one), $right(one));
  end
  int bad [R];   // illegal: a real size
endmodule
