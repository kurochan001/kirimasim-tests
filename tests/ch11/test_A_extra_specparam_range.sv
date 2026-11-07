/*
:name: test_A_extra_specparam_range
:description: A constant primary may be a specparam identifier with a bracketed constant range expression, so a part select of a packed specparam is a constant expression (IEEE 1800-2023 Sections 6.20 and 11.2.1, A.8.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.20.5 A.8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_specparam_range.expected
*/
// IEEE 1800-2023 A.8.4, constant_primary: one alternative is a
// specparam_identifier with the optional "[" constant_range_expression "]".
// §6.20 gives a specparam a packed dimension when one is written before its
// name, so sp is four bits wide. §6.20.5 lets a specparam be part of the
// constant expression of a later specparam declaration, so sp_low takes the
// part select sp[1:0]. sp is 4'hA, so its two low bits are 2, and sp_low
// prints 2.
// A specparam in other constant expressions, such as the condition of a
// generate branch, is left out: §6.20.5 lets a specparam appear in any
// expression that is not assigned to a parameter and is not part of a range,
// but §11.2.1 lists only parameters among the operands of a constant
// expression, and SDF annotation can change a specparam (§6.20.5, 32).

module test_A_extra_specparam_range;
  specparam [3:0] sp = 4'hA;

  specparam [1:0] sp_low = sp[1:0];

  initial $display("%0d", sp_low);
endmodule
