/*
:name: test_sformat_only_second_argument_is_format
:description: $sformat takes its format only from its second argument, which can be a string literal, a string variable or an integral variable, and supports the format specifications of $display, while a later string argument is a value, not a format as it would be for $swrite (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.2.1.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_only_second_argument_is_format.expected
*/
// IEEE 1800-2023 §21.3.3: $sformat always interprets its second argument, and
// only it, as the format. The format can be a string literal or an expression
// of an integral type, an unpacked array of bytes or the string type whose
// content is the format, and it supports all the format specifications of
// $display (21.2.1.1). So "%0d" as third argument is printed by %s as it is,
// while $swrite, which like $fwrite reads format specifications in every
// string literal argument, uses it to print 7. The format "v=%0h" works from a
// string variable and from an integral variable. One format then uses %b, %o,
// %h, %x, %d, %c, %s, %e, %f, %g, %t, %m, %v and %%. The format from an
// unpacked array of bytes and %p are in test_sformat_byte_array_format. The
// 5.052 release of Verilator adds a space after the strength printed by %v.

`timescale 1ns/1ns

module test_sformat_only_second_argument_is_format;
  string s, fs;
  logic [8*5-1:0] fi;
  wire w;
  assign w = 1'b1;

  initial begin
    #1;
    $sformat(s, "<%s%0d>", "%0d", 7);
    $display("sformat later literal: %s", s);
    $swrite(s, "<", "%0d", 7, ">");
    $display("swrite later literal: %s", s);

    fs = "v=%0h";
    $sformat(s, fs, 255);
    $display("string format: %s", s);
    fi = "v=%0h";
    $sformat(s, fi, 171);
    $display("integral format: %s", s);

    $sformat(s, "%b|%o|%h|%x|%0d|%c|%s|%0.1e|%0.2f|%g|%0t|%m|%v|%%",
             4'b1010, 6'o17, 8'hab, 8'hcd, -5, 8'h41, "str", 1500.0, 3.14159, 0.5, $time, w);
    $display("specifiers: %s", s);
  end
endmodule
