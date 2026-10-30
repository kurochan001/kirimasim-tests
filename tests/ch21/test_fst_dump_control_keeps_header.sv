/*
:name: test_fst_dump_control_keeps_header
:description: $dumpoff, $dumpon and $dumpall with an .fst dump leave the file an FST file whose first block is still the FST header (tag 0, section length 329, timescale 1 ns), rather than a VCD file (IEEE 1800-2023 Sections 21.7.1 and 21.7.1.3; FST is a tool format outside the standard)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1 21.7.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fst_dump_control_keeps_header.expected
*/
// IEEE 1800-2023 §21.7.1.3 gives $dumpoff, $dumpon and $dumpall control over
// an open dump. FST is a tool format outside the standard, and §21.7.1.1 has
// $dumpfile name a VCD file, so writing FST is an extension that a simulator
// following the standard does not provide. This test checks that a simulator
// with such an FST backend keeps writing the FST header block (tag
// 0, big-endian section length 329, timescale -9 for 1 ns) after the control
// tasks, so the stream stays FST rather than becoming a VCD file with an .fst
// name. The writer is flushed before the test reads the bytes.

`timescale 1ns/1ns

module test_fst_dump_control_keeps_header;
  logic [7:0] a = 8'h5a;
  byte unsigned hdr[0:8];
  int fd, n;
  longint len;

  initial begin
    $dumpfile("wave.fst");
    $dumpvars(0, test_fst_dump_control_keeps_header);
    #1 a = 8'hA5;
    $dumpoff;
    #1 a = 8'h3c;
    $dumpon;
    #1 a = 8'hc3;
    $dumpall;
    $dumpflush;
    fd = $fopen("wave.fst", "rb");
    if (fd == 0) begin
      $display("open failed");
    end else begin
      n = $fread(hdr, fd);
      $fclose(fd);
      len = 0;
      for (int i = 1; i <= 8; i++) len = (len << 8) | hdr[i];
      $display("bytes=%0d tag=%0d len=%0d", n, hdr[0], len);
    end
    $finish;
  end
endmodule
