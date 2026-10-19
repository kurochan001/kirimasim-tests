/*
:name: test_shift_wider_than_64_bits
:description: Shifts of vectors wider than 64 bits drop the bits shifted out of the expression's width (IEEE 1800-2023 Section 11.4.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10 11.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_wider_than_64_bits.expected
*/
// IEEE 1800-2023 §11.4.10: a left shift moves bits towards the most
// significant end and fills with zeros; bits moved beyond the width of the
// expression are lost. The width is that of the expression context (11.6.1):
// with a 65-bit target, (x << 1) >> 1 loses bit 64 of x, while with a 66-bit
// target x is first extended to 66 bits and bit 64 moves to bit 65.

module test_shift_wider_than_64_bits;
  logic [64:0] x, y;
  logic [65:0] wide;
  logic [99:0] big;

  initial begin
    x = {1'b1, 64'd5};
    y = x << 1;
    $display("65 bits, x << 1: %h", y);
    y = (x << 1) >> 1;
    $display("65 bits, (x << 1) >> 1: %h", y);
    wide = x << 1;
    $display("66 bits, x << 1: %h", wide);
    big = 100'd1 << 99;
    $display("100 bits, 1 << 99: %h", big);
    $display("100 bits, (1 << 99) >> 99: %h, (1 << 99) << 1: %h", big >> 99, big << 1);
  end
endmodule
