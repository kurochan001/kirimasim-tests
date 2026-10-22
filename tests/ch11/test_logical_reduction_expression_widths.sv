/*
:name: test_logical_reduction_expression_widths
:description: Observe one-bit logical and reduction results without shrinking their operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 11.8.1 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical_reduction_expression_widths.expected
*/
// IEEE 11.6.1: one-bit results must not narrow the self-determined
// operands to their zero low bits. IEEE 11.8.1: true comparison/reduction
// of signed inputs widens as unsigned 1, rather than signed all-ones.
module test_logical_reduction_expression_widths;
  logic [3:0] a = 4'b0010;
  logic [8:0] b = 9'b100000000;
  logic [8:0] zero = 0;
  logic signed [3:0] negative = -1;
  logic [15:0] cmp, red;
  initial begin
    $display("logical_bits=%0d %0d %0d %0d",
             $bits(a&&b), $bits(a||b), $bits(a->zero), $bits(a<->b));
    $display("logical_values=%b %b %b %b", a&&b, a||b, a->zero, a<->b);
    $display("reduction_bits=%0d %0d %0d %0d %0d %0d %0d %0d",
             $bits(&a), $bits(~&a), $bits(|a), $bits(~|a),
             $bits(^a), $bits(~^a), $bits(^~a), $bits(!a));
    $display("reduction_values=%b %b %b %b %b %b %b %b",
             &a, ~&a, |a, ~|a, ^a, ~^a, ^~a, !a);
    cmp = negative < 0;
    red = &negative;
    $display("unsigned_results=%h %h", cmp, red);
    $finish;
  end
endmodule
