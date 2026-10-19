/*
:name: test_file_fgetc_ungetc
:description: $fgetc reads one character or returns -1 at the end of the file, and $ungetc pushes a character back for the next $fgetc (IEEE 1800-2023 Section 21.3.4.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.1 21.3.1 21.3.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_fgetc_ungetc.expected
*/
// IEEE 1800-2023 §21.3.4.1: $fgetc returns the next byte of the file, or EOF
// (-1) when it cannot read one; a variable wider than 8 bits tells -1 apart
// from the byte 8'hFF. $ungetc pushes a character back so that the next $fgetc
// returns it, without changing the file, and returns 0 when it succeeds. The
// test creates its file in the current directory.

module test_file_fgetc_ungetc;
  int fd, c, code;

  initial begin
    fd = $fopen("test_file_fgetc_ungetc.txt", "w");
    $fwrite(fd, "AB");
    $fclose(fd);

    fd = $fopen("test_file_fgetc_ungetc.txt", "r");
    c = $fgetc(fd);           $display("fgetc   -> %0d", c);
    code = $ungetc(c, fd);    $display("ungetc  -> %0d", code);
    c = $fgetc(fd);           $display("fgetc   -> %0d", c);
    code = $ungetc(90, fd);   $display("ungetc 90 -> %0d", code);
    c = $fgetc(fd);           $display("fgetc   -> %0d", c);
    c = $fgetc(fd);           $display("fgetc   -> %0d", c);
    c = $fgetc(fd);           $display("fgetc   -> %0d eof=%0d", c, $feof(fd) != 0);
    $fclose(fd);
  end
endmodule
