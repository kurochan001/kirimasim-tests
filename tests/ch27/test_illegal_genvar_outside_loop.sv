/*
:name: test_illegal_genvar_outside_loop
:description: A genvar cannot be referenced outside a loop generate scheme (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure reads the genvar g
:expected_stderr_regex: test_illegal_genvar_outside_loop\.sv:19:
*/
// IEEE 1800-2023 §27.4: a genvar exists only for loop generate schemes and
// cannot be referenced anywhere else; the initial procedure reads g.

module test_illegal_genvar_outside_loop;
  genvar g;
  initial $display("%0d", g);   // illegal: g outside a generate loop
endmodule
