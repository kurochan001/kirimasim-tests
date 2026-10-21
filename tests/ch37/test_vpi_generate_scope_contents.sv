/*
:name: test_vpi_generate_scope_contents
:description: Gen scopes of nested loop generates and of a named conditional generate contain the inner gen scopes, their variables, the genvar of their own loop and the parameters declared in them, all as local parameters (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 37.12 27.4 6.20.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_generate_scope_contents.c
:expected_stdout: @test_vpi_generate_scope_contents.expected
*/
// IEEE 1800-2023 §37.85: a gen scope iterates its internal scopes, among them
// the gen scopes of a loop generate nested in it (37.12), its variables, which
// have it as vpiScope, and its parameters. A reference to a genvar inside the
// gen scope is a local parameter (detail 3; 27.4), and so is a parameter
// declared in it (detail 4): in a generate block the keyword parameter means
// localparam (6.20.4). outer[1] holds the local parameters g = 1, OL = 10 and
// OP = 6 and the gen scopes inner[0] to inner[2]; inner[2] holds only h = 2
// (g belongs to outer[1]) and x, three bits wide; the conditional block cond
// holds CP = 3. Lists are sorted by name.

module test_vpi_generate_scope_contents;
  for (genvar g = 0; g < 2; g++) begin : outer
    parameter int OP = 5 + g;
    localparam int OL = g * 10;
    for (genvar h = 0; h < 3; h++) begin : inner
      logic [h:0] x;
      initial x = '1;
    end
  end

  if (1) begin : cond
    parameter int CP = 3;
    logic y;
    initial y = 1'b1;
  end

  initial #1 $vt_gen;
endmodule
