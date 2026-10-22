/*
:name: test_fseek_cancels_ungetc_and_clears_error
:description: Flushing makes a file readable and repositioning discards pushback while a successful read clears I/O error text (IEEE 1800-2023 Section 21.3.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.5 21.3.6 21.3.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fseek_cancels_ungetc_and_clears_error.expected
*/
// IEEE 1800-2023 21.3.5 21.3.6 21.3.7: Repositioning cancels ungetc. Ferror
// after a successful operation returns zero and clears its string argument; no
// platform-specific error number is assumed.
// Oracle checks: The 5.052 release does not reproduce the clause-derived
// output.

module test_fseek_cancels_ungetc_and_clears_error;
  int fd, writer_fd, rc, c, position, error_code;
  bit [639:0] error_text;
  initial begin
    writer_fd = $fopen("seek.dat", "w");
    if (writer_fd == 0) $fatal(1, "open write failed");
    $fwrite(writer_fd, "abcd"); $fflush(writer_fd);
    fd = $fopen("seek.dat", "r");
    if (fd == 0) $fatal(1, "open read failed");
    rc = $fseek(fd, 0, 0); c = $fgetc(fd); rc = $ungetc(8'h5a, fd);
    rc = $fseek(fd, 2, 0); c = $fgetc(fd); position = $ftell(fd);
    error_text = "stale"; error_code = $ferror(fd, error_text);
    $display("char=%c position=%0d error=%0d empty=%0d", c, position,
             error_code, error_text == 0);
    rc = $rewind(fd); c = $fgetc(fd);
    $display("rewound=%c status=%0d", c, rc);
    $fclose(fd); $fclose(writer_fd);
  end
endmodule
