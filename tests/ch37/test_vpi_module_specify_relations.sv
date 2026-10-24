/*
:name: test_vpi_module_specify_relations
:description: a module iterates the module paths and the timing checks of its specify block, and vpiModule of each leads back to the instance that has it; a module without a specify block has none (IEEE 1800-2023 Section 37.5)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.5 37.39 37.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_module_specify_relations.c
:expected_stdout: @test_vpi_module_specify_relations.expected
*/
// IEEE 1800-2023 §37.5: a module has one-to-many relations to its module
// paths (vpiModPath) and to its timing checks (vpiTchk), and each of them
// has a one-to-one relation back to the module, vpi_handle(vpiModule). c1
// and c2 are instances of a cell whose specify block has three module paths
// and two timing checks. The application prints, for each instance, every
// path by the names of its input and output terminals (vpiModPathIn and
// vpiModPathOut, §37.39) and every timing check by its vpiTchkType (§37.40),
// sorted, each with the instance that vpiModule gives for it. The top module
// has no specify block, so both iterations give no object. The output is
// printed from a cbStartOfSimulation callback. The VPI headers of Icarus
// Verilog 13.0 do not define vpiTchk, and Icarus Verilog 13.0 does not keep
// timing checks; in Verilator 5.052 the iterations give no object.

`timescale 1ns/1ns

module test_vpi_module_specify_relations_cell(input wire a, input wire b, input wire clk,
                                              input wire d, output wire y, output wire z);
  buf (y, a);
  and (z, a, b);

  specify
    (a => y) = 1;
    (a => z) = 2;
    (b => z) = 3;
    $setup(d, posedge clk, 2);
    $hold(posedge clk, d, 1);
  endspecify
endmodule

module test_vpi_module_specify_relations;
  logic a, b, clk, d;
  wire y1, z1, y2, z2;

  test_vpi_module_specify_relations_cell c1(a, b, clk, d, y1, z1);
  test_vpi_module_specify_relations_cell c2(b, a, clk, d, y2, z2);
endmodule
