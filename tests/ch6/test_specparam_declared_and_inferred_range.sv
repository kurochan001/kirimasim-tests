/*
:name: test_specparam_declared_and_inferred_range
:description: A specparam with a declared range has that range while one without a range takes the width of its final assigned value (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_declared_and_inferred_range.expected
*/
// IEEE 1800-2023 §6.20.5: a specparam declaration may have a range, which
// is the range of the parameter; a specparam declared without a range takes
// the range of its final assigned value. The two specparams are read
// through $bits, next to an ordinary parameter that has no range of its own,
// so the declared width and the width taken from the value are compared.
//
// This Verilator release gives the un-ranged specparam 64 bits, so the
// expectation follows 6.20.5.

module test_specparam_declared_and_inferred_range;
  specparam [7:0] fixed = 8'h0F;
  specparam inferred = 4'hA;
  parameter int ordinary = 4;

  initial begin
    $display("fixed=%0d bits=%0d", fixed, $bits(fixed));
    $display("inferred=%0d bits=%0d", inferred, $bits(inferred));
    $display("ordinary=%0d", ordinary);
  end
endmodule
