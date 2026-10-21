/*
:name: test_vpi_path_terms_tchk_args
:description: an edge-sensitive module path gives its instance, the edge of its input term and its data path term with the data polarity; the vpiExpr iteration of a timing check gives tchk terms for the reference and data events and expressions for the other arguments, a reference event with a condition gives it, $period has only its reference event and limit, and vpiDelay of two limits is a list operation (IEEE 1800-2023 Sections 37.39 and 37.40)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.39 37.40 37.3.4 30.4.3 31.3.1 31.3.3 31.4.5 38.10 38.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_path_terms_tchk_args.c
:expected_stdout: @test_vpi_path_terms_tchk_args.expected
*/
// IEEE 1800-2023 §37.39: a mod path gives the module or interface that holds
// it through vpiInstance, its input terms through vpiModPathIn, each with the
// edge written before it (vpiEdge), and the terms of its data source (§30.4.3)
// through vpiModDataPathIn; vpiDataPolarity is the polarity written before the
// colon of the data source; a path without a data source has no data path
// terms, so the iteration is NULL (38.23). §37.40: vpiTchkRefTerm is the
// reference event (or controlled reference event) and vpiTchkDataTerm the data
// event (detail 1): $setup (§31.3.1) has its reference event second and
// $setuphold (§31.3.3) first. A tchk term gives its edge and, after &&&, its
// condition. Iterating vpiExpr over a timing check gives a tchk term for each
// event and, for every other argument, an object of the type of that
// expression (detail 2): constants for the limits and a variable for the
// notifier; $period (§31.4.5) has only its reference event and its limit.
// vpiDelay gives the limits written in the source (§38.10): one limit as an
// expression of that value, two as an operation of type vpiListOp (§37.3.4),
// whose operands are printed sorted. Paths and checks are printed sorted.

module test_vpi_path_terms_tchk_args_cell(input clk, d, en, rst, output q);
  reg qq = 1'b0;
  reg ntfr = 1'b0;

  assign q = qq;
  always @(posedge clk) qq <= d;

  specify
    (posedge clk => (q +: d)) = (3, 4);
    (rst => q) = 2;
    $setuphold(posedge clk, d, 2, 1, ntfr);
    $setup(d, posedge clk &&& en, 5);
    $period(posedge clk, 10);
  endspecify
endmodule

module test_vpi_path_terms_tchk_args;
  logic clk = 0, d = 0, en = 1, rst = 0;
  wire q;

  test_vpi_path_terms_tchk_args_cell u(clk, d, en, rst, q);

  initial #1 $vt_specify;
endmodule
