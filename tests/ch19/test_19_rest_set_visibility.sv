/*
:name: test_19_rest_set_visibility
:description: A set expression is resolved in the scope enclosing the covergroup, where the coverpoint names are not visible, so an enclosing parameter of the same name as the coverpoint provides the range bound (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_rest_set_visibility.expected
*/
// IEEE 1800-2023 §19.5.1.2: the coverpoint and bin identifiers of a
// covergroup are not visible in the set expression of a bin, which is
// evaluated when the covergroup is constructed. The module here declares the
// parameter cp = 2, and the covergroup declares a coverpoint with the same
// name cp. Inside the set expression of that coverpoint, cp can only be the
// module parameter, so bins v[] = {[0:cp]} is the three bins 0, 1 and 2.
// Sampling 0 and 1 leaves one of the three bins uncovered, and sampling 2
// covers the last one. Only whether the coverage has reached 100 is printed;
// the percentage of one or two of three bins depends on the rounding of
// §19.11.1, which the standard does not fix.

module test_19_rest_set_visibility;
  parameter int cp = 2;
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a { bins v[] = {[0:cp]}; }
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
