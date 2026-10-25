/*
:name: test_defparam_last_in_source_text_wins
:description: When several defparam statements in one source text set the same parameter, the parameter takes the value of the last one, whether they are in one module, in one statement with a list, or in different modules (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_last_in_source_text_wins.expected
*/
// IEEE 1800-2023 §23.10.1: when several defparam statements set the same
// parameter, the parameter takes the value of the last defparam statement
// in the source text. (Only when they come from several source files is the
// winner undefined; this test is one file.)
//   m.A is set to 1 and later in the same module to 2: A is 2;
//   m.B is set in one statement with a list, first to 3 and then to 4: B is
//   4;
//   m.C is set to 5 in the top module and to 6 in the module
//   defparam_last_wins_late, a separate top-level module that comes later
//   in the source text: C is 6;
//   m.E is set to 7 in the module defparam_last_wins_early, which comes
//   before the top module, and to 8 in the top module: E is 8.
// Icarus Verilog 13.0 lets the defparam of the top module win for C as
// well and prints C=5, and Verilator 5.052 stops with an error at the second
// defparam of a parameter.

module defparam_last_wins_m;
  parameter int A = 0;
  parameter int B = 0;
  parameter int C = 0;
  parameter int E = 0;
endmodule

module defparam_last_wins_early;
  defparam test_defparam_last_in_source_text_wins.m.E = 7;
endmodule

module test_defparam_last_in_source_text_wins;
  defparam_last_wins_m m();

  defparam m.A = 1;
  defparam m.B = 3, m.B = 4;
  defparam m.C = 5;
  defparam m.E = 8;
  defparam m.A = 2;

  initial #1 $display("m.A=%0d m.B=%0d m.C=%0d m.E=%0d", m.A, m.B, m.C, m.E);
endmodule

module defparam_last_wins_late;
  defparam test_defparam_last_in_source_text_wins.m.C = 6;
endmodule
