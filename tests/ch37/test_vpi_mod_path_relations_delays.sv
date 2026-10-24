/*
:name: test_vpi_mod_path_relations_delays
:description: a module path leads to the module instance that holds it, each of its path terms leads back to it and has the direction of its terminal, and vpi_put_delays changes the delays of a path, which vpi_get_delays reads back and the output then follows (IEEE 1800-2023 Section 37.39)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.39 38.10 38.32 30.4.5 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mod_path_relations_delays.c
:expected_stdout: @test_vpi_mod_path_relations_delays.expected
*/
// IEEE 1800-2023 §37.39: a mod path has a one-to-one relation to the module
// that contains its specify block (vpiModule), here the instance u1 or u2 of
// the two cells; its path terms, from vpiModPathIn and vpiModPathOut, lead
// back to the path with vpiModPath and have vpiDirection, vpiInput for the
// input terminal of a path and vpiOutput for its output terminal. Each path
// connects one scalar input to one scalar output (30.4.5), so that each has
// one input and one output term. The delays of a path are read with
// vpi_get_delays and set with vpi_put_delays, 2 delays being rise and fall
// (38.10, 38.32, 30.5.1), in the time unit of the module, 1 ns. At 10 the
// application reads the delays (2, 4) of the path a => z of u1, sets them to
// (6, 1) and reads them back; z, a buffered copy of a, then rises 6 after a
// rises at 11 and falls 1 after a falls at 21. Paths are printed sorted.
// Icarus Verilog 13.0 gives no vpiDirection (other) and no vpiModPath (NULL)
// for a path term, which the standard defines, and matches the rest.

`timescale 1ns/1ns

module test_vpi_mod_path_relations_delays_cell (input a, b, output y, z);
  and g1 (y, a, b);
  buf g2 (z, a);

  specify
    (a => y) = (3, 5);
    (b => y) = (3, 5);
    (a => z) = (2, 4);
  endspecify
endmodule

module test_vpi_mod_path_relations_delays_other (input c, output w);
  not g3 (w, c);

  specify
    (c => w) = 1;
  endspecify
endmodule

module test_vpi_mod_path_relations_delays;
  logic a = 1'b0, b = 1'b1, c = 1'b0;
  wire y, z, w;

  test_vpi_mod_path_relations_delays_cell u1 (a, b, y, z);
  test_vpi_mod_path_relations_delays_other u2 (c, w);

  always @(z) if ($time > 10) $display("%0t: z = %b", $time, z);

  initial begin
    #10 $vt_paths;
    #1 a = 1'b1;
    #10 a = 1'b0;
    #10 $finish;
  end
endmodule
