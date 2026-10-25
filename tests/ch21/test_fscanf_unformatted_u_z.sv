/*
:name: test_fscanf_unformatted_u_z
:description: $fscanf %u reads as many 32-bit words of binary data as fill its variable, the word with the least significant bits first, into known bits only, and %z reads pairs of 32-bit words as the a and b bits of 4-state values, so x and z can be read (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 21.2.1.1 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_fscanf_unformatted_u_z.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %u transfers enough binary data from
// the input to fill its variable, as 2-state data, so the result has no x or
// z bits; %z transfers the 4-state representation, laid out as an s_vpi_vecval
// structure (38.15): a 32-bit word of a bits and then one of b bits, where a
// bit pair 1,0 is 1, 0,1 is z and 1,1 is x. Both read native-endian 32-bit
// words, the word with the least significant bits first (21.2.1.1). So that
// the result does not depend on the byte order of the host, every word in the
// file has the same bytes in both orders, such as 11 22 22 11. The file holds
// one word for a 32-bit %u, two words for a 64-bit %u, and an a word 0f f0 f0
// 0f with a b word 00 ff ff 00 for a 32-bit %z. The file is created in the
// current directory.

module test_fscanf_unformatted_u_z;
  int fd, n;
  logic [31:0] u32, z32;
  logic [63:0] u64;

  task automatic put(input logic [31:0] w);
    $fwrite(fd, "%c%c%c%c", w[31:24], w[23:16], w[15:8], w[7:0]);
  endtask

  initial begin
    fd = $fopen("test_fscanf_unformatted_u_z.bin", "wb");
    put(32'h11222211);
    put(32'h33444433);
    put(32'h55666655);
    put(32'h0ff0f00f);
    put(32'h00ffff00);
    $fclose(fd);

    fd = $fopen("test_fscanf_unformatted_u_z.bin", "rb");
    n = $fscanf(fd, "%u", u32);
    $display("u32: n=%0d %h unknown=%0d", n, u32, $isunknown(u32));
    n = $fscanf(fd, "%u", u64);
    $display("u64: n=%0d %h unknown=%0d", n, u64, $isunknown(u64));
    n = $fscanf(fd, "%z", z32);
    $display("z32: n=%0d %b", n, z32);
    $fclose(fd);
  end
endmodule
