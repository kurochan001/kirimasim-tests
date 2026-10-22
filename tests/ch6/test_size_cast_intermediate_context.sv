/*
:name: test_size_cast_intermediate_context
:description: Use real size casts to resize arithmetic intermediates and preserve operand signing
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 11.6 11.6.1 20.6.2 20.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_size_cast_intermediate_context.expected
*/
// IEEE 6.24.1 and 11.6: size casts set an intermediate assignment
// context, rather than merely slicing an already sized destination.
// Small and large casts distinguish carry loss, truncation and padding.
// The signed operand stays signed, and the result has one packed range.
// Icarus 13.0 crashes while compiling the array query on a cast result.
module test_size_cast_intermediate_context;
  logic [7:0] a = 8'hff, b = 8'h01;
  logic signed [7:0] negative = -1;
  logic [15:0] direct_sum, narrow_sum, cast_sum;
  logic [15:0] truncated, padded, signed_padded;
  initial begin
    direct_sum = a+b;
    narrow_sum = 8'(a+b);
    cast_sum = 16'(a+b);
    $display("sums=%h %h %h", direct_sum, narrow_sum, cast_sum);
    truncated = 4'(a);
    padded = 12'(a);
    signed_padded = 12'(negative);
    $display("resize=%h %h %h", truncated, padded, signed_padded);
    $display("widths=%0d %0d signedness=%0d %0d",
             $bits(4'(a)), $bits(12'(negative)),
             12'(negative) < 0, 12'(a) < 0);
    $display("shape=%0d %0d bounds=%0d:%0d",
             $dimensions(12'(a)), $unpacked_dimensions(12'(a)),
             $left(12'(a)), $right(12'(a)));
    $finish;
  end
endmodule
