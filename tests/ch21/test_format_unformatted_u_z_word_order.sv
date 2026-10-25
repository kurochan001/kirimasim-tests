/*
:name: test_format_unformatted_u_z_word_order
:description: %u and %U write the 2-state bits of a value in 32-bit words with x and z as 0, and %z and %Z write an aval and bval word per 32 bits, in both cases starting with the word that holds the LSB (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.3.1 21.3.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_format_unformatted_u_z_word_order.expected
*/
// IEEE 1800-2023 §21.2.1.1: %u (or %U) writes the value without formatting
// as its 2-state binary form, an x or z bit being written as 0, and %z (or
// %Z) writes its 4-state form as s_vpi_vecval structures, an aval word
// followed by a bval word (§38.15: 0 is aval 0 bval 0, 1 is 1 0, z is 0 1
// and x is 1 1). Both write units of 32 bits, the unit with the LSB first,
// each in the byte order of the host. A packed structure is written as the
// equivalent vector.
// Each 32-bit word here has four equal bytes, so the bytes in the file do
// not depend on the byte order of the host but do show the order of the
// words and of aval and bval. The file is written with "wb", read back byte
// by byte with $fgetc (§21.3.4.1) and printed 8 bytes to a line:
//   q2 = {2222_2222, 1111_1111} with %u, u4 = {x..x, 4444_4444} with %U,
//   uz = {3333_3333, z..z} with %u, z4 = {5555_5555, z..z} with %z (two
//   lines), zx = x..x with %Z, and the packed structure {hi 6666_6666,
//   lo 7777_7777} with %u.

module test_format_unformatted_u_z_word_order;
  typedef struct packed {
    logic [31:0] hi;
    logic [31:0] lo;
  } pair_t;

  logic [63:0] q2 = {32'h2222_2222, 32'h1111_1111};
  logic [63:0] u4 = {32'hxxxx_xxxx, 32'h4444_4444};
  logic [63:0] uz = {32'h3333_3333, 32'hzzzz_zzzz};
  logic [63:0] z4 = {32'h5555_5555, 32'hzzzz_zzzz};
  logic [31:0] zx = 32'hxxxx_xxxx;
  pair_t pk;
  int fd, c, n;
  logic [7:0] b;

  initial begin
    pk.hi = 32'h6666_6666;
    pk.lo = 32'h7777_7777;
    fd = $fopen("test_format_unformatted_u_z_word_order.bin", "wb");
    $fwrite(fd, "%u", q2);
    $fwrite(fd, "%U", u4);
    $fwrite(fd, "%u", uz);
    $fwrite(fd, "%z", z4);
    $fwrite(fd, "%Z", zx);
    $fwrite(fd, "%u", pk);
    $fclose(fd);
    fd = $fopen("test_format_unformatted_u_z_word_order.bin", "rb");
    n = 0;
    c = $fgetc(fd);
    while (c != -1) begin
      b = c[7:0];
      if (n % 8 == 0) $write("%h", b);
      else $write(" %h", b);
      if (n % 8 == 7) $display;
      n++;
      c = $fgetc(fd);
    end
    $fclose(fd);
    $display("bytes=%0d", n);
  end
endmodule
