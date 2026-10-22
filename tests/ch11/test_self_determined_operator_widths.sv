/*
:name: test_self_determined_operator_widths
:description: Query expression widths before assignment and isolate a concatenated sum
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 11.8.1 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_self_determined_operator_widths.expected
*/
// IEEE 11.6.1: $bits observes the expression itself. All binary rows
// use unequal widths. A concatenation prevents the 64-bit assignment from
// propagating into its component; the direct assignment keeps the carry.
// Unsized constants are checked against a minimum, not a fixed exact width.
module test_self_determined_operator_widths;
  logic [3:0] a = 4'hf;
  logic [8:0] b = 9'h1ff;
  logic [63:0] isolated, contextual;
  initial begin
    $display("binary=%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d",
             $bits(a+b), $bits(a-b), $bits(a*b), $bits(a/b), $bits(a%b),
             $bits(a&b), $bits(a|b), $bits(a^b), $bits(a^~b), $bits(a~^b));
    $display("unary=%0d %0d %0d values=%h %h %h",
             $bits(+a), $bits(-a), $bits(~a), +a, -a, ~a);
    $display("constants=%0d %0d unsized_minimum=%0d %0d",
             $bits(3'b101), $bits(65'h1), $bits(123) >= 32, $bits('h123) >= 32);
    isolated = {a+b};
    contextual = a+b;
    $display("isolated=%h contextual=%h", isolated, contextual);
    $finish;
  end
endmodule
