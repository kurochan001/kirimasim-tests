/*
:name: test_19_rest_set_visibility
:description: A set expression is resolved in the scope enclosing the covergroup, where the coverpoint names are not visible, so an enclosing parameter of the same name as the coverpoint provides a value of the set (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.2 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_19_rest_set_visibility.expected
*/
// IEEE 1800-2023 §19.5.1.2: the coverpoint and bin identifiers of a
// covergroup are not visible in the set expression of a bin, the array
// expression that gives the values of the bin, which is evaluated when the
// covergroup is constructed. The module here declares the parameter cp = 2,
// and the covergroup declares a coverpoint with the same name cp. Inside the
// set expression of that coverpoint, cp can only be the module parameter, so
// bins v[] = vals_t'{0, 1, cp} is the three bins 0, 1 and 2.
// The values are given as an array rather than as a range list in braces,
// such as {[0:cp]}: a range list is not a set expression, and for it only
// §19.5 limits the contexts in which a coverpoint name can be used, which can
// be read as hiding the name or as making such a reference an error.
// Sampling 0 and 1 leaves one of the three bins uncovered, and sampling 2
// covers the last one. Only whether the coverage has reached 100 is printed;
// the percentage of one or two of three bins depends on the rounding of
// §19.11.1, which the standard does not fix.
// The expected output comes from the standard alone: Verilator 5.052 does not
// parse a set expression in a bin, and Icarus Verilog 13.0 has no covergroups.

module test_19_rest_set_visibility;
  parameter int cp = 2;
  typedef int vals_t[3];
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a { bins v[] = vals_t'{0, 1, cp}; }
  endgroup

  cg g;

  initial begin
    g = new;
    a = 0;
    g.sample();
    $display("after 0, below 100: %0d", g.get_inst_coverage() < 100.0);
    a = 1;
    g.sample();
    $display("after 1, below 100: %0d", g.get_inst_coverage() < 100.0);
    a = 2;
    g.sample();
    $display("after 2, at 100: %0d", g.get_inst_coverage() == 100.0);
  end
endmodule
