/*
:name: test_sscanf_digit_sets_xz
:description: $sscanf %b, %o, %h and %x read digits of their radix in either case together with x, X, z, Z, ? and _, %d reads an optional sign and decimal digits with _ or a single x, X, z, Z or ?, and each field ends at the first character outside its set (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sscanf_digit_sets_xz.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %b matches a sequence of 0, 1, x, X,
// z, Z, ? and _; %o adds the digits 2 to 7; %h and %x the digits 0 to 9 and a
// to f in either case. As in source text, _ is skipped.
// %d matches an optional + or - sign and decimal digits with _, or one single
// x, X, z, Z or ?, which makes the whole value unknown or high impedance. A
// field ends at the first character that is not in its set, which is left for
// the next directive: 2 after binary digits, 8 after octal digits, g after
// hexadecimal digits and a after decimal digits. The test prints the values
// and the number of items each call assigned. Table 21-7 lists ? among the
// characters of a number without saying which value it stands for, so for a
// ? digit the test prints only that its bits are unknown or high impedance,
// and the digits read after it show that it did not end the field.

module test_sscanf_digit_sets_xz;
  logic [7:0] b;
  logic [20:0] o;
  logic [31:0] h;
  logic [11:0] x;
  logic signed [15:0] d;
  int k, n;
  string rest;

  initial begin
    n = $sscanf("10xXzZ?_1", "%b", b);
    $display("b: n=%0d %b_%b ?unknown=%0d", n, b[7:2], b[0], $isunknown(b[1]));
    n = $sscanf("0112", "%b%d", b, k);
    $display("b then d: n=%0d %b %0d", n, b, k);

    n = $sscanf("7x_XzZ?1", "%o", o);
    $display("o: n=%0d %o_%o ?unknown=%0d", n, o[20:6], o[2:0], &(o[5:3] ^ o[5:3]) === 1'bx);
    n = $sscanf("1234_567", "%o", o);
    $display("o: n=%0d %0d", n, o);
    n = $sscanf("178", "%o%d", o, k);
    $display("o then d: n=%0d %0d %0d", n, o, k);

    n = $sscanf("aF_xXzZ?9", "%h", h);
    $display("h: n=%0d %h_%h ?unknown=%0d", n, h[31:8], h[3:0], &(h[7:4] ^ h[7:4]) === 1'bx);
    n = $sscanf("01234567", "%h", h);
    $display("h: n=%0d %h", n, h);
    n = $sscanf("89Ab_CdEf", "%h", h);
    $display("h: n=%0d %h", n, h);
    n = $sscanf("Bc_Z", "%x", x);
    $display("x: n=%0d %h", n, x);
    n = $sscanf("1fg", "%h%s", h, rest);
    $display("h then s: n=%0d %h %s", n, h, rest);

    n = $sscanf("+1_234", "%d", d);
    $display("d: n=%0d %0d", n, d);
    n = $sscanf("7890", "%d", d);
    $display("d: n=%0d %0d", n, d);
    n = $sscanf("-5_6", "%d", d);
    $display("d: n=%0d %0d", n, d);
    n = $sscanf("x", "%d", d);
    $display("d: n=%0d %b", n, d);
    n = $sscanf("X", "%d", d);
    $display("d: n=%0d %b", n, d);
    n = $sscanf("z", "%d", d);
    $display("d: n=%0d %b", n, d);
    n = $sscanf("Z", "%d", d);
    $display("d: n=%0d %b", n, d);
    n = $sscanf("?", "%d", d);
    $display("d: n=%0d ?unknown=%0d", n, &(d ^ d) === 1'bx);
    n = $sscanf("12a", "%d%s", d, rest);
    $display("d then s: n=%0d %0d %s", n, d, rest);
  end
endmodule
