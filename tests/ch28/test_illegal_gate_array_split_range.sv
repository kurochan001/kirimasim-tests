/*
:name: test_illegal_gate_array_split_range
:description: one gate instance array name cannot be given two ranges, even when together they would make one continuous range (IEEE 1800-2023 Section 28.3.5)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance array name t_nand is declared with two ranges, [0:1] and [2:3]
:expected_stderr_regex: test_illegal_gate_array_split_range\.sv:25:
*/
// IEEE 1800-2023 §28.3.5: an array of gate instances has one continuous
// range, and an instance name is associated with only one range. Declaring
// the same name a second time with another range, here right after the
// first in the same declaration, is illegal even though [0:1] and [2:3]
// would together cover [0:3]. Giving the two parts different names, as the
// gates u_lo and u_hi do, is legal. Verilator 5.052 accepts the second
// range for t_nand without an error.

module test_illegal_gate_array_split_range;
  wire [3:0] y, z, a, b;
  nand u_lo[0:1] (z[1:0], a[1:0], b[1:0]), u_hi[2:3] (z[3:2], a[3:2], b[3:2]);
  nand t_nand[0:1] (y[1:0], a[1:0], b[1:0]), t_nand[2:3] (y[3:2], a[3:2], b[3:2]);  // illegal
endmodule
