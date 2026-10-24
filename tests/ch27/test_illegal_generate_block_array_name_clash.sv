/*
:name: test_illegal_generate_block_array_name_clash
:description: the name of a loop generate block array cannot be the name of another declaration of the scope, here a net (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the loop generate names its block array lane, which is already the name of a net of the module
:expected_stderr_regex: test_illegal_generate_block_array_name_clash\.sv:(23|27):
*/
// IEEE 1800-2023 §27.4: a named loop generate block declares an array of
// generate block instances, and it is an error if its name is the name of
// any other declaration in the scope. The module declares the net lane and
// then a loop whose blocks are named lane as well; the loop named lanes is
// legal. A tool may report the clash at either declaration. The 5.052
// release of Verilator reports it as "Unsupported in C", which does not
// count.

module test_illegal_generate_block_array_name_clash;
  wire [1:0] lane;
  for (genvar k = 0; k < 2; k++) begin : lanes
    assign lane[k] = 1'b0;
  end
  for (genvar k = 0; k < 2; k++) begin : lane   // illegal
  end
endmodule
