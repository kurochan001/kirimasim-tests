/*
:name: test_file_fflush_ferror
:description: After $fflush, output written through one descriptor can be read through another, and $ferror reports no error after a good operation (IEEE 1800-2023 Section 21.3.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.6 21.3.7 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_fflush_ferror.expected
*/
// IEEE 1800-2023 §21.3.6: $fflush writes out the buffered output of a file.
// So text written with $fwrite and flushed, while the file is still open for
// writing, can be read through a second descriptor opened for reading.
// §21.3.7: when the most recent operation had no error, $ferror returns 0 and
// clears its string argument. Verilator 5.052 puts "Undefined error: 0" in the
// string instead. The test creates its file in the current directory.

module test_file_fflush_ferror;
  int fw, fr, n, err;
  string s, msg;

  initial begin
    fw = $fopen("test_file_fflush_ferror.txt", "w");
    $fwrite(fw, "flushed text\n");
    $fflush(fw);
    fr = $fopen("test_file_fflush_ferror.txt", "r");
    n = $fgets(s, fr);
    msg = "not cleared";
    err = $ferror(fr, msg);
    $display("n=%0d text=[%s] ferror=%0d msg=[%s]", n, s.substr(0, s.len() - 2), err, msg);
    $fclose(fr);
    $fclose(fw);
  end
endmodule
