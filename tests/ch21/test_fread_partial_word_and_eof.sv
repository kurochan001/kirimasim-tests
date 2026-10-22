/*
:name: test_fread_partial_word_and_eof
:description: Binary fread fills packed values most significant byte first and reports short reads at EOF (IEEE 1800-2023 Section 21.3.4.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fread_partial_word_and_eof.expected
*/
// IEEE 1800-2023 21.3.4.4: Available bytes fill the most significant byte
// positions. Byte counts and these positions are checked; unread bits are not.

module test_fread_partial_word_and_eof;
  int fd, count;
  bit [23:0] word_value;
  initial begin
    fd = $fopen("binary.dat", "wb");
    if (fd == 0) $fatal(1, "open write failed");
    $fwrite(fd, "%c%c", 8'h12, 8'h34); $fclose(fd);
    fd = $fopen("binary.dat", "rb");
    if (fd == 0) $fatal(1, "open read failed");
    word_value = 24'haabbcc;
    count = $fread(word_value, fd);
    $display("read=%0d prefix=%h", count, word_value[23:8]);
    count = $fread(word_value, fd);
    $display("eof_read=%0d", count);
    $fclose(fd);
  end
endmodule
