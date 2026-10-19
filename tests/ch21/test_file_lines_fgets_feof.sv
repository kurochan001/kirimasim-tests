/*
:name: test_file_lines_fgets_feof
:description: Writing a text file, reading it back a line at a time with $fgets, and detecting the end with $feof (IEEE 1800-2023 Section 21.3.4.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.2 21.3.1 21.3.2 21.3.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_lines_fgets_feof.expected
*/
// IEEE 1800-2023 §21.3.1: $fopen with a type returns a file descriptor, whose
// bit 31 is always set. §21.3.2: $fdisplay and $fwrite write to it.
// §21.3.4.2: $fgets reads up to and including the next newline, or up to the
// end of the file, and returns the number of characters read, or 0 when
// nothing could be read. §21.3.8: $feof is nonzero once a read has met the end
// of the file. The test creates its file in the current directory.

module test_file_lines_fgets_feof;
  int fd, n;
  string line;

  function automatic string chomp(string s);
    if (s.len() > 0 && s[s.len() - 1] == "\n") return s.substr(0, s.len() - 2);
    return s;
  endfunction

  initial begin
    fd = $fopen("test_file_lines_fgets_feof.txt", "w");
    $display("write fd: nonzero=%0d bit31=%0d", fd != 0, fd[31]);
    $fdisplay(fd, "first line");
    $fwrite(fd, "second %0d\n", 2);
    $fwrite(fd, "no newline at end");
    $fclose(fd);

    fd = $fopen("test_file_lines_fgets_feof.txt", "r");
    $display("read fd: nonzero=%0d bit31=%0d", fd != 0, fd[31]);
    n = $fgets(line, fd);
    $display("n=%0d line=[%s] eof=%0d", n, chomp(line), $feof(fd) != 0);
    n = $fgets(line, fd);
    $display("n=%0d line=[%s] eof=%0d", n, chomp(line), $feof(fd) != 0);
    n = $fgets(line, fd);
    $display("n=%0d line=[%s] eof=%0d", n, chomp(line), $feof(fd) != 0);
    n = $fgets(line, fd);
    $display("n=%0d eof=%0d", n, $feof(fd) != 0);
    $fclose(fd);
  end
endmodule
