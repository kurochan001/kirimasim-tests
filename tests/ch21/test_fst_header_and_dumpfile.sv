/*
:name: test_fst_header_and_dumpfile
:description: $dumpfile with an .fst name creates an FST file whose first block is the FST header (tag 0, section length 329, timescale 1 ns), rather than a VCD file (IEEE 1800-2023 Section 21.7.1; FST is a tool format outside the standard)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fst_header_and_dumpfile.expected
*/
// IEEE 1800-2023 §21.7.1.1 makes $dumpfile name the VCD file, so the standard
// itself asks for a VCD file here. FST is the GTKWave/libfst format, not a
// format of the standard, and writing it for an .fst name is an extension.
// This test is for a simulator that provides that extension, such as
// kirimasim when its FST backend is implemented; a simulator that writes VCD
// as the standard says does not pass it. It checks the bytes of the
// first FST block: tag 0 (FST_BL_HDR), the big-endian section length 329, and
// the timescale byte -9 for 1 ns. A VCD writer starts with "$date" instead, so
// this test also distinguishes an FST file from a VCD file with an .fst name.
// The test flushes the dump before it reads the file; the writer may still hold
// the data otherwise.

`timescale 1ns/1ns

module test_fst_header_and_dumpfile;
  logic [7:0] a = 8'h5a;
  byte unsigned hdr[0:73];
  int fd, n;
  longint len;

  initial begin
    $dumpfile("wave.fst");
    $dumpvars(0, test_fst_header_and_dumpfile);
    #1 a = 8'hA5;
    $dumpflush;
    fd = $fopen("wave.fst", "rb");
    if (fd == 0) begin
      $display("open failed");
    end else begin
      n = $fread(hdr, fd);
      $fclose(fd);
      len = 0;
      for (int i = 1; i <= 8; i++) len = (len << 8) | hdr[i];
      $display("bytes=%0d tag=%0d len=%0d timescale=%0d",
               n, hdr[0], len, $signed(hdr[73]));
    end
    $finish;
  end
endmodule
