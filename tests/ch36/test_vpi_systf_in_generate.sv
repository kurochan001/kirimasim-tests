/*
:name: test_vpi_systf_in_generate
:description: A user-defined system task can be called from an initial procedure in a generate block, with the block index as its argument (IEEE 1800-2023 Sections 36.4 and 27.3)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 27.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_generate.c
:expected_stdout: @test_vpi_systf_in_generate.expected
*/
// IEEE 1800-2023 §27.3: each iteration of the generate loop elaborates a
// block with its own initial procedure. §36.4: the system task $vt_note is
// called there like a built-in task, and its argument is the value of the
// genvar. §36.9.1: the application registers $vt_note from
// vlog_startup_routines. The delay of each iteration is one more than its
// index, so the notes come at 1 and 2 in that order.

`timescale 1ns/1ns

module test_vpi_systf_in_generate;
  genvar i;

  generate
    for (i = 0; i < 2; i++) begin : g
      initial #(i + 1) $vt_note(i);
    end
  endgenerate

  initial #5 $finish;
endmodule
