/*
:name: test_file_fscanf
:description: $fscanf reads fields of a file by a format, skipping white space before them, returns the number of fields assigned, stops at a mismatch leaving the character unread, honors suppression and field widths, and returns EOF at the end of the file (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 21.3.1 21.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_fscanf.expected
*/
// IEEE 1800-2023 §21.3.4.3: $fscanf reads from a file by a format and returns
// the number of input items matched and assigned. White space in the format
// skips white space in the input, and conversions other than %c skip leading
// white space. %* reads a field without assigning it, and a number after %
// is the maximum field width. A conversion that meets a character it cannot
// accept ends the call, and that character stays unread; if the input ends
// before the first conversion, the result is EOF (-1). The test writes its
// file in the current directory (§21.3.1, §21.3.2) and reads it back.

module test_file_fscanf;
  int fd, n, a, d, x, y;
  logic [7:0] h;
  logic [3:0] b;
  real r;
  byte c;
  string s;

  initial begin
    fd = $fopen("test_file_fscanf.txt", "w");
    $fdisplay(fd, "42 ff 101 -7");
    $fdisplay(fd, "name   2.5   Z");
    $fdisplay(fd, "abc 9");
    $fdisplay(fd, "1 2 1234");
    $fwrite(fd, "77");
    $fclose(fd);

    fd = $fopen("test_file_fscanf.txt", "r");
    n = $fscanf(fd, "%d %h %b %d", a, h, b, d);
    $display("n=%0d a=%0d h=%0d b=%0d d=%0d", n, a, h, b, d);
    n = $fscanf(fd, "%s %f %c", s, r, c);
    $display("n=%0d s=%s r=%.1f c=%s", n, s, r, c);
    n = $fscanf(fd, "%d", x);
    $display("n=%0d, a letter where a number is expected", n);
    n = $fscanf(fd, "%s %d", s, x);
    $display("n=%0d s=%s x=%0d", n, s, x);
    n = $fscanf(fd, "%*d %d %2d%d", x, y, d);
    $display("n=%0d x=%0d y=%0d d=%0d", n, x, y, d);
    n = $fscanf(fd, "%d", x);
    $display("n=%0d x=%0d", n, x);
    n = $fscanf(fd, "%d", x);
    $display("n=%0d at the end", n);
    $fclose(fd);
  end
endmodule
