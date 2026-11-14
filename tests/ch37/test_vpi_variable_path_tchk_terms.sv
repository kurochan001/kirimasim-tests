/*
:name: test_vpi_variable_path_tchk_terms
:description: A variable that is the destination of a module path gives its output path term with vpi_handle(vpiPathTerm), a variable that is the data event of a timing check gives its timing check terminal with vpi_handle(vpiTchkTerm), and both relations give NULL for a variable that is not such a terminal (IEEE 1800-2023 Sections 37.17, 37.39 and 37.40)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.39 37.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_variable_path_tchk_terms.c
:expected_stdout: @test_vpi_variable_path_tchk_terms.expected
*/
// IEEE 1800-2023 §37.17: the variables diagram draws one-to-one relations
// (a single arrowhead) from a variable to a path term and to a tchk term, so
// an application reaches them with vpi_handle(vpiPathTerm) and
// vpi_handle(vpiTchkTerm); for nets, 37.16 draws one-to-many relations
// instead. A module path destination may be a variable connected to an output
// port (30.3), and a timing check terminal may be an input port, here one
// declared as a variable. In vptt_cell the module path a => y makes the
// output variable y an output path term (vpiDirection vpiOutput, 37.39), and
// $setup(d, posedge clk, 1) makes the input variable d the data event, a tchk
// term without an edge (vpiEdge vpiNoEdge, 37.40). The vpiExpr of each term
// is the variable it was reached from. The output variable z is neither, and
// y and d are terminals of only one kind, so the other relations give NULL.

`timescale 1ns/1ns

module vptt_cell (input wire a, input wire clk, input var logic d,
                  output var logic y, output var logic z);
  assign y = a;
  assign z = a;

  specify
    (a => y) = 2;
    $setup(d, posedge clk, 1);
  endspecify
endmodule

module test_vpi_variable_path_tchk_terms;
  wire a, clk, y, z;
  logic d;

  vptt_cell c (.a(a), .clk(clk), .d(d), .y(y), .z(z));

  initial #1 $vt_terms;
endmodule
