/*
:name: test_illegal_always_comb_function_target_written_by_initial
:description: A variable assigned inside a function that an always_comb procedure calls is a target of the always_comb, so it cannot also be written by an initial procedure (IEEE 1800-2023 Section 9.2.2.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: y is assigned by the function put, which the always_comb procedure calls, and by an initial procedure
:expected_stderr_regex: test_illegal_always_comb_function_target_written_by_initial\.sv:(32|35|39):
*/
// IEEE 1800-2023 §9.2.2.2: the variables on the left-hand side of the
// assignments of an always_comb shall not be assigned by any other process,
// and they include the variables assigned within the functions that the
// always_comb calls. The first always_comb calls the void function put,
// which assigns y; the second one assigns z, and nothing else writes z,
// which is legal.
// The second initial procedure writes y, so the design is illegal; a tool
// can report it at the assignment in put, at the call in the always_comb or
// at the write in the initial procedure. Without that initial procedure the
// design is legal and prints y=5 z=2.
// Icarus Verilog 13.0 and the 5.054 release of Verilator accept the
// design.

module test_illegal_always_comb_function_target_written_by_initial;
  logic [3:0] a = 4'd2, b = 4'd3;
  logic [3:0] y, z;

  function automatic void put(logic [3:0] v);
    y = v;                 // illegal: y is a target of the always_comb
  endfunction

  always_comb put(a + b);  // illegal: through this call
  always_comb z = a;

  initial #1 $display("y=%0d z=%0d", y, z);
  initial #2 y = 4'd0;     // illegal: and another process writes y
endmodule
