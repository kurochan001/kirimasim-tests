/*
:name: test_include_fifteen_levels
:description: Fifteen levels of nested `include work: each included file declares a parameter from the one of the file that includes it and then includes the next file (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:incdirs: include_depth_ch22
:expected_stdout: @test_include_fifteen_levels.expected
*/
// IEEE 1800-2023 §22.4: an included file can contain `include directives; a
// tool may limit the nesting, but the limit shall be at least 15 levels. The
// module includes depth_level01.svh, which includes depth_level02.svh, and so
// on down to depth_level15.svh, the fifteenth level, all found through the
// include directory include_depth_ch22 (:incdirs:). The file of level k
// declares DEPTH_Lk as DEPTH_L(k-1) + k, so DEPTH_L15 is 1 + 2 + ... + 15 =
// 120 only if all fifteen files were read, in order.

module test_include_fifteen_levels;
  `include "depth_level01.svh"

  initial $display("DEPTH_L01=%0d DEPTH_L08=%0d DEPTH_L15=%0d", DEPTH_L01, DEPTH_L08, DEPTH_L15);
endmodule
