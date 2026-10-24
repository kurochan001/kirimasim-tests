/*
:name: test_illegal_generate_genvar_unknown_bit
:description: a loop generate scheme that sets a bit of its genvar to x is an error (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the iteration of loop bad adds STEP, which has an x bit, so the genvar gets x bits
:expected_stderr_regex: test_illegal_generate_genvar_unknown_bit\.sv:25:
*/
// IEEE 1800-2023 §27.4: it is an error if any bit of the genvar is set to x
// or z while the loop generate scheme is evaluated. Loop good steps by the
// known value 1; loop bad steps by STEP, whose bit 1 is x, so after the
// first block the genvar has x bits.

module test_illegal_generate_genvar_unknown_bit;
  localparam logic [3:0] ONE = 4'b0001;
  localparam logic [3:0] STEP = 4'b00x1;
  for (genvar i = 0; i < 4; i = i + ONE) begin : good
    int v = i;
  end
  for (genvar i = 0; i < 4; i = i + STEP) begin : bad   // illegal
    int v = i;
  end
endmodule
