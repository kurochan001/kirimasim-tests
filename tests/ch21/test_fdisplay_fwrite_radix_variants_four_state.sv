/*
:name: test_fdisplay_fwrite_radix_variants_four_state
:description: $fdisplayh and $fdisplayo write an argument without a format in hexadecimal or octal with leading zeros and the x, X, z and Z digits of four-state groups, and end the line, while $fwriteb and $fwriteo write binary or octal and do not (IEEE 1800-2023 Section 21.3.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.2 21.2.1.1 21.2.1.2 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_fdisplay_fwrite_radix_variants_four_state.expected
*/
// IEEE 1800-2023 §21.3.2: $fdisplayh, $fdisplayo, $fwriteb and $fwriteo
// take the arguments of $displayh, $displayo, $writeb and $writeo after a
// descriptor, and write to the file it names. §21.2.1.1: an argument with
// no format of its own is shown in hexadecimal by the h form, octal by the
// o form and binary by the b form; a format in a string argument still
// applies to the argument that follows it. §21.2.1.2: the field is as wide
// as the largest value of the expression needs, and outside decimal the
// leading zeros are written. §21.2.1.3: a hexadecimal or octal digit whose
// bits are all x or all z is x or z; a digit with some x bits is X, and one
// with some z bits and no x bit is Z. $fdisplay ends its output with a new
// line and $fwrite does not.
// p = 10'b10_xxxx_01z0 is 2xZ in hexadecimal and 1XXZ in octal (the groups
// 1, 0xx, xx0 and 1z0); q = 12'h0a5 is 0a5 and 0245; s = -3 in 8 bits is
// fd, 375 and 11111101; the 32-bit n = 42 is 0000002a and 00000000052. Two
// $fwriteb calls and two $fwriteo calls each make one line, which ends at
// the "\n" of the second call. The file is written to the current
// directory, then read back and printed line by line.

module test_fdisplay_fwrite_radix_variants_four_state;
  localparam string FILE = "test_fdisplay_fwrite_radix_variants_four_state.txt";
  logic [9:0] p = 10'b10_xxxx_01z0;
  logic [11:0] q = 12'h0a5;
  logic signed [7:0] s = -8'sd3;
  int n = 42;
  int fd, r;
  string line;

  initial begin
    fd = $fopen(FILE, "w");
    $fdisplayh(fd, "h p=", p, " q=", q, " s=", s, " n=", n, " d=%0d", n);
    $fdisplayo(fd, "o p=", p, " q=", q, " s=", s, " n=", n, " h=%h", q);
    $fwriteb(fd, "b p=", p, " s=", s);
    $fwriteb(fd, " q=", q, "\n");
    $fwriteo(fd, "o2 q=", q);
    $fwriteo(fd, " s=", s, "\n");
    $fclose(fd);
    fd = $fopen(FILE, "r");
    r = $fgets(line, fd);
    while (r > 0) begin
      $write("file: %s", line);
      r = $fgets(line, fd);
    end
    $fclose(fd);
    $display("end of file");
  end
endmodule
