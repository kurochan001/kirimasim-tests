/*
:name: test_readmemh_address_range
:description: $readmemh with start and finish addresses that lie outside the highest dimension of a multidimensional unpacked array issues a warning and leaves every word of the memory unchanged (IEEE 1800-2023 Sections 21.4 and 21.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4 21.4.3 21.4.1 7.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemh_address_range.expected
*/
// IEEE 1800-2023 §21.4: the optional start and finish arguments of
// $readmemh are addresses of the unpacked array, which are the addresses of
// its highest dimension, and §21.4.3: an address entry in the file likewise
// addresses only the words of the highest dimension. The highest dimension
// of logic [7:0] m[0:1][0:2] is [0:1], so the addresses 2 and 5 lie outside
// the memory; §21.4 then requires a warning and no change to any word. The
// test prints every word after the load. §21.4.1: each word of the file is
// a vector. §7.4.4: a word of this memory is a single 8-bit element.
//
// Icarus Verilog 13.0 and 14.0 and Verilator 5.052 take start and finish as
// linear word positions and load m[0][2] to m[1][2], the result this test
// used to expect; docs/simulator-differences.md lists that difference.

module test_readmemh_address_range;
  logic [7:0] m[0:1][0:2];
  int fd;
  int i, j;

  initial begin
    for (i = 0; i < 2; i = i + 1)
      for (j = 0; j < 3; j = j + 1) m[i][j] = 8'hee;
    fd = $fopen("test_readmemh_address_range.txt", "w");
    $fdisplay(fd, "11 22");
    $fdisplay(fd, "33 44");
    $fclose(fd);
    $readmemh("test_readmemh_address_range.txt", m, 2, 5);
    foreach (m[i, j]) $display("m[%0d][%0d]=%h", i, j, m[i][j]);
  end
endmodule
