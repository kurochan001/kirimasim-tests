/*
:name: test_operator_unary_binary_token_boundaries
:description: Adjacent unary and binary operators retain their separate roles (IEEE 1800-2023 Section 5.5)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_unary_binary_token_boundaries.expected
*/
// IEEE 1800-2023 5.5: Unary minus following subtraction must be distinguished
// from decrement; shifts and comparisons have different token lengths.

module test_operator_unary_binary_token_boundaries;
  int a = 6, b = 2;
  initial begin
    $display("minus=%0d shift=%0d compare=%0d", a- -b, a << b, a <= b);
    a--;
    $display("decrement=%0d", a);
  end
endmodule
