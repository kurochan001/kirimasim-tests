/*
:name: test_shortreal_ieee754_single
:description: shortreal values have the IEEE 754 single format: $shortrealtobits gives the single-precision bits, and a value that needs more precision is rounded to the nearest single (IEEE 1800-2023 Section 6.13)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.13 6.12 20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortreal_ieee754_single.expected
*/
// IEEE 1800-2023 §6.12 and its footnote (shown with 6.13): shortreal is the
// same as a C float and is represented as IEEE Std 754 describes, in the
// 32-bit single format. $shortrealtobits and $bitstoshortreal (20.5) convert
// between a shortreal and its bits.
// 1.0, -0.75 and 0.1 show their single-precision bits (0.1 rounded to the
// nearest single). 1.0 + 2**-30 is closer to 1.0 than to the next single, so
// stored in a shortreal it is 1.0, while 1.0 + 2**-23 is the next single,
// 32'h3f800001.
// Oracle checks: Icarus Verilog 13.0 keeps 1.0 + 2**-30 in the shortreal
// without rounding it (tiny == 1.0 gives 0), and the 5.052 release stores
// shortreal as real, so neither gives the expected output.

module test_shortreal_ieee754_single;
  shortreal a = 1.0;
  shortreal b = -0.75;
  shortreal c = 0.1;
  shortreal tiny = 1.0 + 2.0 ** -30;
  shortreal next = 1.0 + 2.0 ** -23;

  initial begin
    $display("bits: %h %h %h", $shortrealtobits(a), $shortrealtobits(b), $shortrealtobits(c));
    $display("1 + 2**-30: %h equal to 1.0 %0d", $shortrealtobits(tiny), tiny == 1.0);
    $display("1 + 2**-23: %h equal to 1.0 %0d", $shortrealtobits(next), next == 1.0);
    $display("from bits: %0d", $bitstoshortreal(32'h3f800001) == next);
  end
endmodule
