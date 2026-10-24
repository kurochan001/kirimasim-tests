/*
:name: test_vpi_tchk_relations_path_delays
:description: a timing check leads to the module instance that holds it, its reference and data terms lead back to it, and vpi_put_delays changes its limit, which vpi_get_delays reads back; vpiDelay of a module path gives the constant for one delay and a list operation for two and for six (IEEE 1800-2023 Sections 37.40 and 37.39)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.40 37.39 37.3.4 38.10 38.32 31.3.1 31.3.2 31.4.4 30.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_tchk_relations_path_delays.c
:expected_stdout: @test_vpi_tchk_relations_path_delays.expected
*/
// IEEE 1800-2023 §37.40: a tchk has a one-to-one relation to the module that
// contains its specify block, here u1 for $setup and $hold and u2 for $width;
// vpiTchkRefTerm and vpiTchkDataTerm give its tchk terms, the reference and
// the data event (detail 1; $width has no data event, 31.4.4), and each term
// leads back to its check through vpiTchk. The limits of a check are read and
// set with vpi_get_delays and vpi_put_delays, with as many delays as the check
// has limits, one here (38.10, 38.32): the application sets the limit 4 of
// $setup to 7 and the limit 5 of $width to 8 and reads them back, in the time
// unit of the modules, 1 ns. §37.39: vpiDelay of a mod path gives the delay
// written in the source, which by §37.3.4 is an expression evaluating to the
// constant for one delay, (a => y) = 3, and an operation of type vpiListOp
// for more, (d => z) = (1, 2) and the six delays of clk => w (30.5.1), whose
// operands are printed sorted, as are the checks and the paths.

`timescale 1ns/1ns

module test_vpi_tchk_relations_path_delays_one (input clk, d, a, output y);
  reg n1 = 1'b0, n2 = 1'b0;

  buf g1 (y, a);

  specify
    (a => y) = 3;
    $setup(d, posedge clk, 4, n1);
    $hold(posedge clk, d, 2, n2);
  endspecify
endmodule

module test_vpi_tchk_relations_path_delays_two (input clk, d, output z, w);
  buf g2 (z, d);
  buf g3 (w, clk);

  specify
    (d => z) = (1, 2);
    (clk => w) = (1, 2, 3, 4, 5, 6);
    $width(posedge clk, 5);
  endspecify
endmodule

module test_vpi_tchk_relations_path_delays;
  logic clk = 1'b0, d = 1'b0, a = 1'b0;
  wire y, z, w;

  test_vpi_tchk_relations_path_delays_one u1 (clk, d, a, y);
  test_vpi_tchk_relations_path_delays_two u2 (clk, d, z, w);

  initial #1 $vt_specify;
endmodule
