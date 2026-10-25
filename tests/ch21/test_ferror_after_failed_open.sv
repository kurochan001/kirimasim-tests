/*
:name: test_ferror_after_failed_open
:description: After $fopen fails to open a file for reading, $ferror returns a nonzero error code and writes a description of the error into its string argument, and after a later successful read it returns 0 and clears the string (IEEE 1800-2023 Section 21.3.7)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.7 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ferror_after_failed_open.expected
*/
// IEEE 1800-2023 §21.3.7: $ferror(fd, str) writes a description of the error
// of the most recent file I/O operation into str and returns the integral
// error code; if that operation had no error, it returns 0 and clears str.
// §21.3.1: opening a file that does not exist with "r" returns 0, and $ferror
// tells the cause. The code and the text depend on the host, so the test
// prints only whether the code is nonzero and the text not empty; then a file
// that exists is opened and read, and $ferror reports no error. The file is
// created in the current directory. After the good read, the 5.052 release
// of Verilator still returns the code and text of the failed open.

module test_ferror_after_failed_open;
  int fd, code;
  string msg;
  bit [639:0] msg_bits;

  initial begin
    fd = $fopen("test_ferror_after_failed_open_missing.txt", "r");
    msg = "";
    code = $ferror(fd, msg);
    $display("missing file: fd=%0d code nonzero=%0d text not empty=%0d", fd, code != 0,
             msg.len() != 0);
    msg_bits = '0;
    code = $ferror(fd, msg_bits);
    $display("into 640 bits: code nonzero=%0d text not empty=%0d", code != 0, msg_bits != 0);

    fd = $fopen("test_ferror_after_failed_open.txt", "w");
    $fwrite(fd, "x");
    $fclose(fd);
    fd = $fopen("test_ferror_after_failed_open.txt", "r");
    void'($fgetc(fd));
    msg = "stale";
    code = $ferror(fd, msg);
    $display("after a good read: code=%0d text=[%s]", code, msg);
    $fclose(fd);
  end
endmodule
