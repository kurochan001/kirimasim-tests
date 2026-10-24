/*
:name: test_illegal_unpacked_port_dimension_count
:description: An unpacked array port and the array connected to it need the same number of unpacked dimensions, even when the element counts are equal (IEEE 1800-2023 Section 23.3.3.5)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port p of u has one unpacked dimension of 4 elements and is connected to the array m with two unpacked dimensions of 2 elements each
:expected_stderr_regex: test_illegal_unpacked_port_dimension_count\.sv:27:
*/
// IEEE 1800-2023 §23.3.3.5: for an unpacked array port, the port and the
// array connected to it shall have the same number of unpacked dimensions,
// and each dimension the same size. The port p has one dimension of size 4.
// The instance ok connects the array a [4], which matches; u connects m
// [2][2], which also has four elements but two dimensions.

module upd_child(input logic [7:0] p [4]);
endmodule

module test_illegal_unpacked_port_dimension_count;
  logic [7:0] a [4];
  logic [7:0] m [2][2];
  upd_child ok (.p(a));
  upd_child u (.p(m));   // illegal: two unpacked dimensions for one
endmodule
