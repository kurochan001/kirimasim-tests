/*
:name: test_signed_unsigned_keep_size_and_bits
:description: $signed and $unsigned return the same size and bits as their argument, x and z included, interpreted as signed or unsigned (IEEE 1800-2023 Section 20.5)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 11.7 11.8.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_signed_unsigned_keep_size_and_bits.expected
*/
// IEEE 1800-2023 §20.5: $signed and $unsigned change the signedness of an
// expression but not its type: they return a value of the same size and
// value as the argument, signed for $signed and unsigned for $unsigned.
// §11.8.1: a signed operand is sign-extended to the width of the context and
// an unsigned one is zero-extended.
// The 8-bit pattern f0 is extended to 32 bits as -16 through $signed and as
// 240 through $unsigned, and in a signed 9-bit context it gives 111110000
// and 011110000. $bits shows that the size stays 8, %b that the bits, x and
// z included, stay the same, and the comparisons with 0 that the result is
// signed or unsigned, and $isunknown that x and z are still there.

module test_signed_unsigned_keep_size_and_bits;
  logic [7:0] a = 8'hf0;
  logic signed [7:0] sa = 8'shf0;
  logic [3:0] x4 = 4'b1x0z;
  logic signed [3:0] sx4 = 4'sb1x0z;
  bit [7:0] b8 = 8'h80;
  int r1, r2;
  logic signed [8:0] w1, w2;

  initial begin
    r1 = $signed(a);
    r2 = $unsigned(sa);
    w1 = $signed(a);
    w2 = $unsigned(sa);
    $display("ext: %0d %0d %b %b", r1, r2, w1, w2);
    $display("bits: %0d %0d %0d %0d", $bits($signed(a)), $bits($unsigned(sa)),
             $bits($signed(x4)), $bits($unsigned(b8)));
    $display("pattern: %h %h %b %b", $signed(a), $unsigned(sa), $signed(x4), $unsigned(sx4));
    $display("sign: %0d %0d %0d %0d", $signed(a) < 0, $unsigned(sa) < 0, a < 0, sa < 0);
    $display("unknown: %0d %0d", $isunknown($signed(x4)), $isunknown($unsigned(sx4)));
  end
endmodule
