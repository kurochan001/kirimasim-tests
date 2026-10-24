/*
:name: test_illegal_unpacked_range_z_bound
:description: a bound of a fixed-size unpacked dimension cannot contain a z bit (IEEE 1800-2023 Section 7.4.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the second bound of the unpacked dimension of bad contains a z bit
:expected_stderr_regex: test_illegal_unpacked_range_z_bound\.sv:30:
*/
// IEEE 1800-2023 §7.4.2: each bound of a fixed-size unpacked dimension given
// as a range may be any integer value, positive, negative or zero, in either
// order, but without x or z bits. The legal arrays use negative bounds in
// both orders, a zero bound and a single-element range, and the legal
// design prints their element counts and left bounds.
// The second bound of bad is a constant with a z bit.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_unpacked_range_z_bound;
  int down [3:-1];
  int up [-2:1];
  int one [0:0];
  initial begin
    $display("%0d %0d %0d", $size(down), $size(up), $size(one));
    $display("%0d %0d %0d", $left(down), $left(up), $left(one));
  end
  int bad [0:2'bz1];   // illegal: z bit in a bound
endmodule
