/*
:name: test_illegal_generate_genvar_z_bit
:description: a loop generate scheme that gives its genvar a z bit is an error (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the initialization of loop bad assigns START, whose bit 2 is z, to the genvar
:expected_stderr_regex: test_illegal_generate_genvar_z_bit\.sv:25:
*/
// IEEE 1800-2023 §27.4: it is an error if any bit of the genvar is set to x
// or z while the loop generate scheme is evaluated. Loop good starts from the
// known value KNOWN; loop bad starts from START, whose bit 2 is z, so the
// genvar has a z bit from its initialization on.

module test_illegal_generate_genvar_z_bit;
  localparam logic [3:0] KNOWN = 4'b0100;
  localparam logic [3:0] START = 4'b0z00;
  for (genvar i = KNOWN; i < 6; i = i + 1) begin : good
    int v = i;
  end
  for (genvar i = START; i < 6; i = i + 1) begin : bad   // illegal
    int v = i;
  end
endmodule
