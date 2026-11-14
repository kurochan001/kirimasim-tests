/*
:name: test_file_read_functions_on_r_and_r_plus_descriptors
:description: A file descriptor opened with "r", "rb", "r+", "r+b" or "rb+" can be read with $fgetc, $ungetc, $fgets, $fscanf and $fread, each read starting where the previous one stopped, and opening a file that does not exist with "r" gives 0 (IEEE 1800-2023 Section 21.3.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_read_functions_on_r_and_r_plus_descriptors.expected
*/
// IEEE 1800-2023 §21.3.4: the file read functions read from a file whose
// descriptor was opened with the type r or r+ (with or without b, §21.3.1);
// the reads take the data in order from the position that the previous read
// left. The test writes "AB\n12 34\nWXYZ" with "w" and opens it once with each
// of the five types "r", "rb", "r+", "r+b" and "rb+". Through each descriptor
// it reads the first character with $fgetc, pushes it back with $ungetc
// (which returns 0) and reads it again, reads the rest of the line with
// $fgets (2 characters, "B" and the newline), the two numbers with $fscanf
// (2 conversions, the trailing blank of the format skipping the newline),
// the last four bytes into a 32-bit variable with $fread (4 bytes, the first
// one in the most significant byte, §21.3.4.4), and finally gets EOF (-1)
// from $fgetc. The update types do not truncate the file (§21.3.1), so every
// descriptor sees the same contents. $fopen of a missing file with "r" gives
// 0. The test creates its files in the current directory.

module test_file_read_functions_on_r_and_r_plus_descriptors;
  string name = "test_file_read_functions_on_r_and_r_plus_descriptors.txt";
  string modes[5] = '{"r", "rb", "r+", "r+b", "rb+"};
  int fd, c1, c2, c3, pushed, got, scanned, n_read, last, a, b;
  string line;
  logic [31:0] w;

  initial begin
    fd = $fopen(name, "w");
    $fwrite(fd, "AB\n12 34\nWXYZ");
    $fclose(fd);

    foreach (modes[i]) begin
      a = 0;
      b = 0;
      w = 0;
      line = "";
      fd = $fopen(name, modes[i]);
      c1 = $fgetc(fd);
      pushed = $ungetc(c1, fd);
      c2 = $fgetc(fd);
      got = $fgets(line, fd);
      scanned = $fscanf(fd, "%d %d ", a, b);
      n_read = $fread(w, fd);
      last = $fgetc(fd);
      $fclose(fd);
      $display("%s: open=%0d getc=%c ungetc=%0d getc=%c fgets=%0d:%s", modes[i], fd != 0,
               c1, pushed, c2, got, line.substr(0, 0));
      $display("%s: fscanf=%0d:%0d,%0d fread=%0d:%h eof=%0d", modes[i], scanned, a, b,
               n_read, w, last);
    end

    fd = $fopen("test_file_read_functions_on_r_and_r_plus_descriptors_missing.txt", "r");
    $display("missing file with r: fd=%0d", fd);
  end
endmodule
