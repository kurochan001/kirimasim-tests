/*
:name: test_defparam_assignment_lists
:description: one defparam statement with a list of four assignments to parameters of different instances and depths, with a plain constant expression and with a min:typ:max expression whose three values are equal, observed through the parameter values and a width that a parameter sets (IEEE 1800-2023 Sections 23.10.1, A.2.3, A.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 11.11 A.2.3 A.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_defparam_assignment_lists.expected
*/
// IEEE 1800-2023 A.2.3: a defparam statement holds one or more defparam
// assignments separated by commas; A.2.4: each is the hierarchical name of a
// parameter, =, and a constant min:typ:max expression. §23.10.1: each
// assignment changes the parameter of the instance its name reaches, here
// u1.P and u1.W one level down, m.u_in.P two levels down and u2.R; u2.P,
// which no assignment names, keeps its default 1. W sets the width of v, so
// $bits(u1.v) is 4 + 3. §11.11 leaves to the tool which of the three values
// of a min:typ:max expression is used, so the three values are equal (5).
// Icarus Verilog 13.0 and the other release stop with a syntax error at the
// min:typ:max expression written without parentheses, which the grammar of
// A.2.4 allows; with parentheses both print the expected output.

module dp_leaf #(parameter int P = 1, parameter W = 2, parameter real R = 0.5);
  logic [W-1:0] v;
endmodule

module dp_mid;
  dp_leaf u_in ();
endmodule

module test_defparam_assignment_lists;
  dp_leaf u1 ();
  dp_leaf u2 ();
  dp_mid m ();

  defparam u1.P = 10, u1.W = 4 + 3, m.u_in.P = 5:5:5, u2.R = 2.5;

  initial begin
    $display("u1.P=%0d u1.W=%0d bits=%0d", u1.P, u1.W, $bits(u1.v));
    $display("u2.P=%0d u2.R=%0.2f m.u_in.P=%0d", u2.P, u2.R, m.u_in.P);
  end
endmodule
