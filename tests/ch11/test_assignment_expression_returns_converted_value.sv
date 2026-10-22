/*
:name: test_assignment_expression_returns_converted_value
:description: An assignment expression returns the value after conversion into its narrow target (IEEE 1800-2023 Section 11.3.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_expression_returns_converted_value.expected
*/
// IEEE 1800-2023 11.3.6: The enclosing expression receives the converted stored
// value, not the wider original right hand side.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_assignment_expression_returns_converted_value;
  bit [3:0] narrow;
  int result;
  initial begin
    result = (narrow = 8'hfe);
    $display("stored=%h expression=%0d", narrow, result);
  end
endmodule
