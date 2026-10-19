/*
:name: test_file_seek_tell_rewind
:description: $ftell reports the position of the next read, $fseek moves it from the start, the current position or the end, and $rewind returns to the start and cancels $ungetc (IEEE 1800-2023 Section 21.3.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.5 21.3.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_seek_tell_rewind.expected
*/
// IEEE 1800-2023 §21.3.5: $ftell returns the offset from the start of the file
// of the byte the next operation reads. $fseek(fd, offset, op) moves to offset
// bytes from the start (op 0), from the current position (op 1) or from the
// end (op 2). $rewind moves to the start. Moving the position cancels a pending
// $ungetc (21.3.4.1). After $fseek(fd, -3, 2), Verilator 5.052 reads EOF and
// reports position 7. The test creates its file in the current directory.

module test_file_seek_tell_rewind;
  int fd, c, code;

  initial begin
    fd = $fopen("test_file_seek_tell_rewind.txt", "w");
    $fwrite(fd, "0123456789");
    $fclose(fd);

    fd = $fopen("test_file_seek_tell_rewind.txt", "r");
    $display("ftell at start: %0d", $ftell(fd));
    code = $fseek(fd, 4, 0);
    c = $fgetc(fd);
    $display("fseek(4, 0) code=%0d, read %c, ftell %0d", code, c, $ftell(fd));
    code = $fseek(fd, 2, 1);
    c = $fgetc(fd);
    $display("fseek(2, 1) code=%0d, read %c, ftell %0d", code, c, $ftell(fd));
    code = $fseek(fd, -3, 2);
    c = $fgetc(fd);
    $display("fseek(-3, 2) code=%0d, read %c, ftell %0d", code, c, $ftell(fd));
    code = $ungetc(88, fd);
    code = $rewind(fd);
    c = $fgetc(fd);
    $display("after ungetc and rewind: read %c, ftell %0d", c, $ftell(fd));
    $fclose(fd);
  end
endmodule
