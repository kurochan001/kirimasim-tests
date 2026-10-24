/*
:name: test_cast_shortreal_round_vs_bit_pattern
:description: a shortreal converted to int or to 32 bits by assignment or cast is rounded, losing its fraction, while $shortrealtobits and $bitstoshortreal convert to and from its bit pattern without loss (IEEE 1800-2023 Section 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.2 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_shortreal_round_vs_bit_pattern.expected
*/
// IEEE 1800-2023 §6.24.1: assigning or casting a shortreal to int or to a
// 32-bit vector rounds its value to the nearest integer (§6.12.2, a tie
// rounds away from zero): 3.375 becomes 3, 2.5 becomes 3 and -2.5 becomes
// -3. The result is the number, not the bit pattern, so converting 3 back
// gives 3.0 and the fraction is lost. $shortrealtobits gives the IEEE 754
// single precision pattern instead (3.375 is 32'h40580000, -2.5 is
// 32'hc0200000), and $bitstoshortreal turns it back into 3.375 (§20.5).
// The 5.052 release of Verilator returns the 64-bit double precision
// pattern from $shortrealtobits (c004000000000000 for -2.5, and 0 in the
// low 32 bits for 3.375).

module test_cast_shortreal_round_vs_bit_pattern;
  typedef bit [31:0] u32_t;
  shortreal a = 3.375;
  shortreal h = 2.5;
  shortreal n = -2.5;
  int i;
  bit [31:0] w;
  bit [31:0] pattern;
  shortreal back_num, back_bits;

  initial begin
    i = a;
    w = a;
    $display("assign: int=%0d bit32=%0d", i, w);
    $display("cast: %0d %0d %0d u32=%0d", int'(a), int'(h), int'(n), u32_t'(a));
    back_num = i;
    $display("numeric round trip: %0.3f", back_num);
    pattern = $shortrealtobits(a);
    $display("bits: %h %h", pattern, $shortrealtobits(n));
    back_bits = $bitstoshortreal(pattern);
    $display("bits round trip: %0.3f", back_bits);
  end
endmodule
