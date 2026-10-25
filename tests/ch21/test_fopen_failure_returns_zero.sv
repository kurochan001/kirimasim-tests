/*
:name: test_fopen_failure_returns_zero
:description: $fopen returns 0 when the file cannot be opened, for a missing file with each of the read and read-update types and for a path in a missing directory with and without a type, and $ferror then reports an error (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1 21.3.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fopen_failure_returns_zero.expected
*/
// IEEE 1800-2023 §21.3.1: when a file cannot be opened, because it does not
// exist and the type is "r", "rb", "r+", "r+b" or "rb+", or because it cannot
// be opened at that path, $fopen returns 0 as the descriptor, and $ferror
// can then tell the cause of the error. §21.3.7: $ferror returns a nonzero
// error code and writes a description into its string argument after an
// operation that failed. The text and the code depend on the operating
// system, so only whether they are nonzero and nonempty is printed.
// A file that does not exist is opened with the five read types, a file in a
// directory that does not exist is opened for writing with "w" and without a
// type, and as a contrast an existing file is opened with "r" and "r+".
// The test creates its files in the current directory.

module test_fopen_failure_returns_zero;
  localparam string MISSING = "test_fopen_failure_returns_zero_missing.txt";
  localparam string NODIR = "test_fopen_failure_returns_zero_nodir/file.txt";
  localparam string PRESENT = "test_fopen_failure_returns_zero_present.txt";
  int fd, err;
  string msg;

  initial begin
    fd = $fopen(MISSING, "r");
    err = $ferror(fd, msg);
    $display("r=%0d err=%0d msg=%0d", fd, err != 0, msg.len() != 0);
    fd = $fopen(MISSING, "rb");
    $display("rb=%0d", fd);
    fd = $fopen(MISSING, "r+");
    $display("r+=%0d", fd);
    fd = $fopen(MISSING, "r+b");
    $display("r+b=%0d", fd);
    fd = $fopen(MISSING, "rb+");
    $display("rb+=%0d", fd);
    fd = $fopen(NODIR, "w");
    err = $ferror(fd, msg);
    $display("nodir w=%0d err=%0d msg=%0d", fd, err != 0, msg.len() != 0);
    fd = $fopen(NODIR);
    $display("nodir mcd=%0d", fd);
    fd = $fopen(PRESENT, "w");
    $fdisplay(fd, "here");
    $fclose(fd);
    fd = $fopen(PRESENT, "r");
    $display("present r nonzero=%0d", fd != 0);
    $fclose(fd);
    fd = $fopen(PRESENT, "r+");
    $display("present r+ nonzero=%0d", fd != 0);
    $fclose(fd);
  end
endmodule
