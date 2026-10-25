/*
:name: test_illegal_checker_writes_input
:description: A checker cannot modify its input formal argument (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2 17.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an always_comb procedure of the checker assigns the input formal a
:expected_stderr_regex: test_illegal_checker_writes_input\.sv:24:
*/
// IEEE 1800-2023 17.2: an input checker formal argument shall not be modified
// by the checker. The always_comb procedure below writes the input a, which is
// legal as an always_comb statement (§17.5) but not as a write to an input
// formal. The rest of the design is legal. Verilator 5.052 supports the
// unit-level checker and rejects the write with an error on that line; Icarus
// Verilog 13.0 does not support checkers at all.

`timescale 1ns/1ns

checker write_input(input logic [3:0] a, output logic [3:0] y);
  always_comb a = 4'd0;   // illegal
  assign y = a;
endchecker : write_input

module test_illegal_checker_writes_input;
  logic [3:0] v = 4'd5;
  logic [3:0] y;

  write_input u(.a(v), .y(y));

  initial #1 $display("y=%0d", y);
endmodule
