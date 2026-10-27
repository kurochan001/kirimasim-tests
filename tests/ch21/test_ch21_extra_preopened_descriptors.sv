/*
:name: test_ch21_extra_preopened_descriptors
:description: STDIN, STDOUT and STDERR are pre-opened file descriptors 32'h8000_0000, 32'h8000_0001 and 32'h8000_0002, and output written to the STDOUT descriptor reaches standard output while output written to STDERR stays on standard error (IEEE 1800-2023 Section 21.3.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch21_extra_preopened_descriptors.expected
*/
// IEEE 1800-2023 §21.3.1: a file descriptor is a 32-bit value whose MSB is
// set, and three of them are pre-opened: STDIN is 32'h8000_0000 and is open
// for reading, STDOUT is 32'h8000_0001 and STDERR is 32'h8000_0002, both
// open for append. $ferror (§21.3.7) reports the error status of an open
// descriptor; zero means that no error is pending. The test asks for the
// status of each of the three pre-opened descriptors, writes "out1 " and
// "out2" through the STDOUT descriptor value, and writes a line through the
// STDERR descriptor. Only the STDOUT lines are part of the comparison, so a
// simulator that sent the STDERR line to standard output would fail; the
// test does not depend on how the three descriptors are otherwise used.

module test_ch21_extra_preopened_descriptors;
  string msg_in, msg_out, msg_err;
  int err_in, err_out, err_err;

  initial begin
    err_in  = $ferror(32'h8000_0000, msg_in);
    err_out = $ferror(32'h8000_0001, msg_out);
    err_err = $ferror(32'h8000_0002, msg_err);
    $display("stdin=%0d stdout=%0d stderr=%0d", err_in, err_out, err_err);
    $fwrite(32'h8000_0001, "out1 ");
    $fwrite(32'h8000_0002, "this line belongs to standard error\n");
    $fwrite(32'h8000_0001, "out2\n");
  end
endmodule
