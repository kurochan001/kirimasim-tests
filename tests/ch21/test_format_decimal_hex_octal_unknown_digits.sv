/*
:name: test_format_decimal_hex_octal_unknown_digits
:description: %d shows x or z for a value whose bits are all unknown or all high impedance and X or Z when only some are, and %h and %o apply the same rule to each digit group (IEEE 1800-2023 Section 21.2.1.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.3 21.2.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_format_decimal_hex_octal_unknown_digits.expected
*/
// IEEE 1800-2023 §21.2.1.3: in decimal format a value is shown as one
// character when it has unknown or high-impedance bits: x when all bits are
// x, z when all bits are z, X when some but not all bits are x, and Z when
// some but not all bits are z and none is x (X when there are both). The
// character sits right-justified in the field (§21.2.1.2): an 8-bit value
// takes 3 columns, %0d takes 1 and %5d takes 5. In hexadecimal and octal
// format the same rule applies to each group of 4 or 3 bits, with a normal
// digit for a group without x or z.
// The first two lines show the five decimal cases (all x, all z, some x,
// some z, both x and z) in the automatic width, in the minimum width and in a
// width of 5. The third and fourth lines show hexadecimal and octal groups
// that are all x, all z, partly x, partly z, partly x and z, and known.

module test_format_decimal_hex_octal_unknown_digits;
  logic [7:0] ax = 8'bxxxxxxxx;
  logic [7:0] az = 8'bzzzzzzzz;
  logic [7:0] px = 8'b1010xx01;
  logic [7:0] pz = 8'b1010zz01;
  logic [7:0] pxz = 8'b10x0zz01;
  logic [15:0] h1 = 16'bxxxx_zzzz_01x1_0z10;
  logic [11:0] h2 = 12'bxz01_1z0x_0101;
  logic [8:0] o1 = 9'bxxx_zzz_0x1;
  logic [8:0] o2 = 9'b1z0_xz0_111;

  initial begin
    $display("[%d][%d][%d][%d][%d]", ax, az, px, pz, pxz);
    $display("[%0d][%0d][%0d][%0d][%5d][%5d]", ax, az, px, pz, az, pz);
    $display("[%h][%h]", h1, h2);
    $display("[%o][%o]", o1, o2);
  end
endmodule
