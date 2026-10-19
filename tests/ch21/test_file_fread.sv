/*
:name: test_file_fread
:description: $fread fills an integral variable from the file big endian, fills a memory word by word from its lowest address or from a start address, at most count words, and returns the number of bytes read (IEEE 1800-2023 Section 21.3.4.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.4 21.3.1 21.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_file_fread.expected
*/
// IEEE 1800-2023 §21.3.4.4: $fread(v, fd) reads as many bytes as fill the
// integral variable v, the first byte into the most significant bits.
// $fread(mem, fd, start, count) loads words of the memory from address start,
// or from its lowest address when start is omitted, toward its highest
// address, at most count words, or until the memory is full; a 16-bit word
// takes 2 bytes. The result is the number of bytes read. The test writes the
// bytes 01 to 10 (hex) to a file in the current directory (§21.3.1, §21.3.2)
// and reads them back.

module test_file_fread;
  int fd, n;
  logic [15:0] w;
  logic [7:0] m8 [0:5];
  logic [15:0] down [3:1];

  initial begin
    fd = $fopen("test_file_fread.bin", "wb");
    for (int i = 1; i <= 16; i++) $fwrite(fd, "%c", i[7:0]);
    $fclose(fd);

    foreach (m8[i]) m8[i] = 8'hee;
    foreach (down[i]) down[i] = 16'heeee;
    fd = $fopen("test_file_fread.bin", "rb");
    n = $fread(w, fd);
    $display("n=%0d w=%h", n, w);
    n = $fread(m8, fd, 2, 3);
    $display("n=%0d m8=%h %h %h %h %h %h", n, m8[0], m8[1], m8[2], m8[3], m8[4], m8[5]);
    n = $fread(down, fd);
    $display("n=%0d down[1]=%h down[2]=%h down[3]=%h", n, down[1], down[2], down[3]);
    n = $fread(m8, fd, , 2);
    $display("n=%0d m8=%h %h %h %h %h %h", n, m8[0], m8[1], m8[2], m8[3], m8[4], m8[5]);
    $fclose(fd);
  end
endmodule
