/*
:name: test_ungetc_pushback_and_failed_descriptor
:description: $ungetc returns 0 and makes the pushed character the next $fgetc result while the file keeps its bytes, and $ungetc and $ftell return EOF (-1) for the descriptor of a failed $fopen (IEEE 1800-2023 Sections 21.3.4.1 and 21.3.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.1 21.3.5 21.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ungetc_pushback_and_failed_descriptor.expected
*/
// IEEE 1800-2023 §21.3.4.1: $ungetc(c, fd) puts c into the buffer of fd, so
// the next $fgetc on fd returns c; the file itself does not change. It
// returns 0 when it succeeds and EOF (-1) when the character cannot be pushed
// onto the descriptor. §21.3.5: $ftell returns the offset of the next byte,
// and EOF (-1) when an error occurs.
// The file holds the bytes P Q R. After P is read, Z is pushed back and comes
// out of the next $fgetc, followed by Q, so the pushed character neither
// replaced nor skipped a byte; Y is pushed back after Q in the same way. The
// file is then read again from a new descriptor: it still holds P Q R and
// three bytes. A failed $fopen of a file that does not exist returns 0
// (§21.3.1), which names no open file, so pushing a character onto it and
// asking it for its position are errors. The test creates its file in the
// current directory.

module test_ungetc_pushback_and_failed_descriptor;
  int fd, bad, c, code, pos;

  initial begin
    fd = $fopen("test_ungetc_pushback_and_failed_descriptor.txt", "wb");
    $fwrite(fd, "PQR");
    $fclose(fd);

    fd = $fopen("test_ungetc_pushback_and_failed_descriptor.txt", "rb");
    c = $fgetc(fd);
    pos = $ftell(fd);
    $display("read %0d, position %0d", c, pos);
    code = $ungetc(90, fd);
    $display("ungetc 90 -> %0d", code);
    c = $fgetc(fd);
    $display("read %0d", c);
    c = $fgetc(fd);
    $display("read %0d", c);
    code = $ungetc(89, fd);
    $display("ungetc 89 -> %0d", code);
    c = $fgetc(fd);
    $display("read %0d", c);
    c = $fgetc(fd);
    $display("read %0d", c);
    c = $fgetc(fd);
    $display("read %0d", c);
    $fclose(fd);

    fd = $fopen("test_ungetc_pushback_and_failed_descriptor.txt", "rb");
    $write("file again:");
    for (c = $fgetc(fd); c != -1; c = $fgetc(fd)) $write(" %0d", c);
    $display;
    code = $fseek(fd, 0, 2);
    $display("size %0d", $ftell(fd));
    $fclose(fd);

    bad = $fopen("test_ungetc_pushback_and_failed_descriptor_missing.txt", "r");
    code = $ungetc(65, bad);
    pos = $ftell(bad);
    $display("failed open: fd %0d, ungetc -> %0d, ftell -> %0d", bad, code, pos);
  end
endmodule
