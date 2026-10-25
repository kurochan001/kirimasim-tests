/*
:name: test_number_grammar_every_base_digit_and_real_form
:description: Integral numbers in each base with and without a size, with s or S and either letter case of the base, every digit including x, X, z, Z and ?, underscores after the first digit, decimal numbers of a single x or z digit, real numbers in fixed-point and exponent form with and without an exponent sign, and the unbased unsized literals (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7 5.7.1 5.7.2 A.8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_number_grammar_every_base_digit_and_real_form.expected
*/
// IEEE 1800-2023 §5.7 and A.8.7: a number is an integral number (decimal,
// binary, octal or hexadecimal) or a real number. §5.7.1: a based number is
// an optional size, the base (an apostrophe, an optional s or S and one of
// d D b B o O h H, without spaces inside) and the value, whose first character
// is a digit and whose later characters are digits or underscores, which are
// ignored. The size, the base and the value are separate tokens, so spaces may
// stand between them. A based number is unsigned unless the base has s or S,
// and a simple decimal number is signed. Binary, octal and hexadecimal digits
// include x or X and z, Z or ?, which set 1, 3 or 4 bits; a decimal value can
// be one x or z digit (followed by underscores), which sets every bit, also
// of a 12-bit variable that an unsized 'dx or 'DZ_ is assigned to.
// Hexadecimal letters have either case. An unsized number has 32 bits.
// §5.7.2: a real number is a fixed-point number (digits on both sides of the
// point) or digits, an optional fraction, e or E, an optional + or - and the
// exponent, and its type is real. '0, '1, 'x, 'X, 'z and 'Z set every bit of
// their context, and are 1 bit wide when self-determined.
//
// Each line prints numbers of one kind: values in %b where bits are x or z,
// signed numbers in %0d (an 8-bit pattern 11001000 prints -56 when signed and
// 200 when not), sizes with $bits, and reals with four decimals. 2e1 / 8 is a
// real division, so it prints 2.5000 and not 2.

module test_number_grammar_every_base_digit_and_real_form;
  logic [11:0] u0, u1, ux, uX, uz, uZ, dx12, dz12;

  initial begin
    u0 = '0;
    u1 = '1;
    ux = 'x;
    uX = 'X;
    uz = 'z;
    uZ = 'Z;
    dx12 = 'dx;
    dz12 = 'DZ_;
    $display("dec %0d %0d %0d %0d %0d %0d", 1_234_567_890, 5 'D 3, 'd255, 8'd200, 8'sd200,
             8'Sd200);
    $display("decxz %b %b %b %b %b", 16'dx_, 8'DZ__, 4'd?, dx12, dz12);
    $display("bin %b %0d %0d %0d", 8'B1x0z_?X1Z, 4'b1110, 4'sB1110, 'b1_01);
    $display("oct %b %0d %0d", 12'o7_x2z, 'O01234567, 6'So77);
    $display("hex %h %h %h %b %0d", 40'h01234_56789, 24'hAbCdEf, 24'HaBcDeF, 16'h?X0f, 8'shF0);
    $display("bits %0d %0d %0d %0d %0d %0d", $bits(5 'D 3), $bits('d255), $bits(1_000),
             $bits(12'o7_x2z), $bits('h1_0), $bits('b1_01));
    $display("real %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f", 1.5, 2.5e1, 1E-2, 3e+2, 1_0.2_5,
             7.5E-1);
    $display("realdiv %0.4f", 2e1 / 8);
    $display("unb %b %b %b %b %b %b %0d", u0, u1, ux, uX, uz, uZ, $bits('1));
  end
endmodule
