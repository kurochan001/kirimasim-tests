/*
:name: test_A_extra_spec_option
:description: A coverage specification or option takes attribute instances before a coverpoint, a cross or an option assignment, option.member takes an expression and type_option.member a constant expression, and the group accepts a sample (IEEE 1800-2023 Sections 19.5, 19.7 and 19.7.1, A.2.11)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.7 19.7.1 A.2.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_spec_option.expected
*/
// IEEE 1800-2023 A.2.11, coverage_spec_or_option: each entry of a covergroup
// body is zero or more attribute instances followed by a coverage_spec (a
// cover_point or a cover_cross) or a coverage_option, plus a semicolon.
// coverage_option is option.member_identifier = expression or
// type_option.member_identifier = constant_expression. The bins body also
// takes an option assignment and an attribute before each bins item.
//
// The covergroup cg has an attributed instance option from the expression 1,
// an attributed type option from the constant 5, two attributed coverpoints,
// an attributed cross and an attributed option in the first coverpoint. One
// sample is taken and the test reports that the sample was accepted. Verilator
// 5.052 does not make a coverpoint or the definition-time comments readable
// through the instance, so a coverage percentage or comment value of this
// group is not printed.
//
// Icarus Verilog 13.0 has no covergroup declaration, so the expected output
// is recorded with the 5.052 release of the other simulator.

module test_A_extra_spec_option;
  bit [1:0] v = 0;
  bit [1:0] w = 1;

  covergroup cg;
    (* o1 *) option.per_instance = 1;
    (* o2 *) type_option.weight = 5;
    (* p1 *) cp: coverpoint v {
      (* b1 *) bins each[] = {0, 1, 2, 3};
      (* b2 *) option.weight = 2;
    }
    (* p2 *) cp2: coverpoint w;
    (* c1 *) cx: cross cp, cp2;
  endgroup

  cg g = new;

  initial begin
    g.sample();
    $display("sampled");
    $finish;
  end
endmodule
