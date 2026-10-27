/*
:name: test_23_extra_instance_unpacked_dims
:description: An unpacked connection to an array of instances must match the instance-array sizes in its outermost dimensions, so a four-by-eight connection to an eight-by-four instance array is an error (IEEE 1800-2023 Section 23.3.3.5)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked connection a is [4][8], but the instance array iu u[8][4] needs the outermost dimensions 8 and 4 in that order
:expected_stderr_regex: test_23_extra_instance_unpacked_dims\.sv:34:
*/
// IEEE 1800-2023 §23.3.3.5: if the port connection is an unpacked array,
// the slowest-varying unpacked dimensions of the connection are compared
// with the dimensions of the instance array. If they match exactly in size,
// each element of the connection is matched to the port left index to left
// index and right index to right index; if they do not match, it shall be
// considered an error. The port p of iu is [8][4], and the connection a is
// [4][8], so its slowest-varying dimension has 4 elements against the 8 of
// the instance array. The design is therefore illegal. The ports and the
// connection have the same total number of elements, so only the order and
// size of the outermost dimensions make it wrong.
// The 5.052 release of Verilator reports the dimension mismatch at this
// line; Icarus Verilog 13.0 stops with an internal assertion on this
// instance array, so the expected rejection is recorded with Verilator
// alone.

module iu(input int p [8][4]);
endmodule

module test_23_extra_instance_unpacked_dims;
  int a [4][8];
  iu u[8][4](a);
endmodule
