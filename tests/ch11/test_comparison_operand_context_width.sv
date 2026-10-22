/*
:name: test_comparison_operand_context_width
:description: Compare unequal-width operands and prevent enclosing assignments from leaking into them
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.6.1 11.8.2 20.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparison_operand_context_width.expected
*/
// IEEE 11.6.1 and 11.8.2: comparisons return one unsigned bit. The
// four-bit operand extends to nine bits instead of narrowing its peer.
// A 64-bit assignment must not propagate into comparison operands: the
// nine-bit sum wraps before comparison and a true result zero-extends.
module test_comparison_operand_context_width;
  logic [3:0] a = 4'hf;
  logic [8:0] b = 9'h10f;
  logic [8:0] maximum = 9'h1ff;
  logic [63:0] result;
  initial begin
    $display("bits=%0d %0d %0d %0d %0d %0d %0d %0d",
             $bits(a<b), $bits(a<=b), $bits(a>b), $bits(a>=b),
             $bits(a==b), $bits(a!=b), $bits(a===b), $bits(a!==b));
    $display("values=%b %b %b %b %b %b %b %b",
             a<b, a<=b, a>b, a>=b, a==b, a!=b, a===b, a!==b);
    result = (maximum + 9'd1) == 9'd0;
    $display("independent_unsigned_result=%h", result);
    $finish;
  end
endmodule
