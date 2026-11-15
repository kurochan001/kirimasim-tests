/*
:name: test_illegal_always_comb_target_written_by_initial
:description: A variable that an always_comb procedure assigns directly cannot also be written by an initial procedure (IEEE 1800-2023 Section 9.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: y is assigned by an always_comb procedure and, as the whole variable, by an initial procedure
:expected_stderr_regex: test_illegal_always_comb_target_written_by_initial\.sv:(29|33):
*/
// IEEE 1800-2023 §9.2.2.2: the variables on the left-hand side of the
// assignments of an always_comb shall not be assigned by any other process.
// The first always_comb assigns y and the second one assigns z; nothing
// else writes z, which is legal. The second initial procedure writes the
// whole of y, the same longest static prefix as the write in the always_comb,
// so the design is illegal; a tool can report it at either of the two writes
// of y. Without that initial procedure the design is legal and prints
// y=5 z=2.
// Icarus Verilog 13.0 and the 5.054 release of Verilator accept the
// design.

module test_illegal_always_comb_target_written_by_initial;
  logic [3:0] a = 4'd2, b = 4'd3;
  logic [3:0] y, z;

  always_comb y = a + b;   // illegal: y is written here
  always_comb z = a;

  initial #1 $display("y=%0d z=%0d", y, z);
  initial #2 y = 4'd0;     // illegal: and here
endmodule
