/*
:name: test_A_extra_specparam_range
:description: A constant primary may be a specparam identifier with a bracketed constant range expression, so a part select of a packed specparam is a constant expression (IEEE 1800-2023 Sections 6.20 and 11.2.1, A.8.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.20.5 A.8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_specparam_range.expected
*/
// IEEE 1800-2023 A.8.4, constant_primary: one alternative is a
// specparam_identifier with the optional "[" constant_range_expression "]".
// §6.20 gives a specparam a packed dimension when one is written before its
// name, so sp is four bits wide. §6.20.5 lets a specparam appear in any
// expression that is not assigned to a parameter and is not part of the range
// of a declaration, so the part select sp[1:0] selects a generate branch,
// which requires a constant expression. sp is 4'hA, so its two low bits are
// 2 and the branch prints 2.
//
// The 5.052 release of Verilator treats a specparam name as a variable and
// rejects it in a constant expression, so the expected output is recorded
// with Icarus Verilog 13.0.

module test_A_extra_specparam_range;
  specparam [3:0] sp = 4'hA;

  generate
    if (sp[1:0] == 2'd2) begin : g
      initial $display("%0d", sp[1:0]);
    end
  endgenerate
endmodule
