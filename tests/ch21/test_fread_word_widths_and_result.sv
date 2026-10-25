/*
:name: test_fread_word_widths_and_result
:description: $fread fills each element from whole bytes, the first byte into the most significant bits, so a 24-bit word takes 3 bytes and a 12-bit word 2 bytes whose excess high bits are dropped; start and count are ignored for an integral variable; the result is the number of bytes read, and 0 at the end of the file or on a descriptor that cannot be read (IEEE 1800-2023 Section 21.3.4.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.4 21.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fread_word_widths_and_result.expected
*/
// IEEE 1800-2023 §21.3.4.4: $fread reads the file byte by byte. A memory
// element takes as many bytes as its width needs, 3 for 24 bits and 2 for 12
// bits, read big endian: the first byte fills the most significant part of the
// element. When the width is not a multiple of 8, the bits that do not fit are
// lost, so the bytes 8b 8c give the 12-bit word b8c. start and count are
// ignored for an integral variable, which takes 4 bytes for 32 bits although
// count is 1. The result is the number of bytes read, and 0 when an error
// occurs; at the end of the file nothing can be read, and a descriptor opened
// for writing cannot be read (21.3.4). The file holds the bytes 81 to 90
// (hex); $fgetc shows the byte that follows the 12-bit words. The last byte
// alone goes into the high byte of w32, whose other bits are not printed. The
// file is created in the current directory. The 5.052 release of Verilator
// returns 4 for $fread(w32, fd, 3, 1) but does not fill w32.

module test_fread_word_widths_and_result;
  int fd, fw, n, c;
  logic [31:0] w32;
  logic [23:0] m24 [0:1];
  logic [11:0] m12 [0:1];

  initial begin
    fd = $fopen("test_fread_word_widths_and_result.bin", "wb");
    for (int i = 'h81; i <= 'h90; i++) $fwrite(fd, "%c", i[7:0]);
    $fclose(fd);

    fd = $fopen("test_fread_word_widths_and_result.bin", "rb");
    n = $fread(w32, fd, 3, 1);
    $display("integral with start and count: n=%0d w32=%h", n, w32);
    n = $fread(m24, fd);
    $display("24-bit words: n=%0d %h %h", n, m24[0], m24[1]);
    n = $fread(m12, fd);
    c = $fgetc(fd);
    $display("12-bit words: n=%0d %h %h next=%h", n, m12[0], m12[1], c[7:0]);
    n = $fread(w32, fd);
    $display("short read: n=%0d high byte=%h", n, w32[31:24]);
    n = $fread(w32, fd);
    $display("at the end: n=%0d", n);
    $fclose(fd);

    fw = $fopen("test_fread_word_widths_and_result_w.bin", "wb");
    $fwrite(fw, "%c%c%c%c", 8'h01, 8'h02, 8'h03, 8'h04);
    n = $fread(w32, fw);
    $display("write-only descriptor: n=%0d", n);
    $fclose(fw);
  end
endmodule
