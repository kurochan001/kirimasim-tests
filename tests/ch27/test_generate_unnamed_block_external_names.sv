/*
:name: test_generate_unnamed_block_external_names
:description: unnamed generate blocks get the external name genblk<n> after the number of their generate construct, with leading zeros added while that name is already declared (IEEE 1800-2023 Section 27.6)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.6 38.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_generate_unnamed_block_external_names.c
:expected_stdout: @test_generate_unnamed_block_external_names.expected
*/
// IEEE 1800-2023 §27.6: for external interfaces such as VPI, an unnamed
// generate block is called genblk<n>, where n numbers the generate
// constructs of its scope in textual order, 1 for the first; a named
// construct also takes its number. If genblk<n> is already declared in the
// scope, zeros are put in front of the number until the name is free.
// Here the third construct of the module would be genblk3, but genblk3 and
// genblk03 are declared as localparams, so it has to be genblk003. Inside
// the named loop lp, the first construct is numbered 1 again.
// At the start of the simulation the VPI application (§38.21,
// vpi_handle_by_name) looks up each variable under the names it has to have
// and under names it must not have, and prints whether it was found and,
// if so, its value.

module test_generate_unnamed_block_external_names;
  localparam int genblk3 = 7;
  localparam int genblk03 = 8;

  // construct 1: unnamed case generate block, genblk1
  case (genblk3)
    7: logic [3:0] p = 4'd5;
    default: logic [3:0] q = 4'd6;
  endcase

  // construct 2: the named loop lp; inside it, its own construct 1
  for (genvar k = 0; k < 2; k++) begin : lp
    if (k == 1) logic [3:0] r = 4'd9;
  end

  // construct 3: genblk3 and genblk03 are taken, so genblk003
  if (genblk03 == 8) logic [3:0] s = 4'd3;

  // construct 4: unnamed loop, genblk4[0] and genblk4[1]
  for (genvar k = 0; k < 2; k++) logic [3:0] t = 4'(k + 10);

  initial #1 $display("design: done");
endmodule
