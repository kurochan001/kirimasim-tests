/*
:name: test_display_radix_tasks
:description: the b, o and h forms of $display, $write, $strobe and $monitor print arguments without a format specification in binary, octal or hexadecimal, with leading zeros to the full size, where plain $display uses decimal with leading spaces, and format specifications still apply (IEEE 1800-2023 Section 21.2.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1 21.2.1.2 21.2.1.3 21.2.2 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_display_radix_tasks.expected
*/
// IEEE 1800-2023 §21.2.1: $displayb, $displayo and $displayh, and the same
// forms of $write, $strobe (§21.2.2) and $monitor (§21.2.3), use binary, octal
// or hexadecimal as the default radix of arguments that have no format
// specification; $display and $write use decimal. §21.2.1.2: values printed
// in hexadecimal, octal or binary have leading zeros up to the size of the
// expression, and decimal values have leading spaces. A string literal with
// format specifications is still a format. §21.2.1.3: a hexadecimal digit
// with x and z bits prints as X, one with only z bits as z.

module test_display_radix_tasks;
  logic [7:0] b8 = 8'h05;
  logic [11:0] o12 = 12'o0712;
  int i = -2;
  logic [7:0] xz = 8'b1x0z_zzzz;

  initial begin
    $displayb(b8, " ", 3'd2);
    $displayo(o12, " ", b8);
    $displayh(b8, " ", i);
    $display(b8, " ", i);
    $displayh(xz);
    $displayb(xz);
    $writeh(b8, " ");
    $writeo(b8, " ");
    $writeb(b8);
    $write("\n");
    $displayh("dec %0d, hex ", b8, b8);
    $strobeh(b8);
    b8 = 8'hc3;
    #1;
    $monitorb(b8);
    #1 b8 = 8'h3c;
    #1 $finish;
  end
endmodule
