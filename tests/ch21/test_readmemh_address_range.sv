/*
:name: test_readmemh_address_range
:description: $readmemh with start and finish addresses fills only those words of a multidimensional unpacked array, in row-major order, and leaves the other words unchanged (IEEE 1800-2023 Section 21.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.3 21.4.1 7.4.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemh_address_range.expected
*/
// IEEE 1800-2023 §21.4.3: the optional start and finish arguments of
// $readmemh bound the addresses that are loaded. For a multidimensional
// unpacked array the addresses run in row-major order, the rightmost dimension
// varying fastest, so addresses 2 to 5 of a [0:1][0:2] array are m[0][2] and
// m[1][0], m[1][1] and m[1][2]. The other words keep the value they had
// before. §21.4.1: each word is read as a vector. §7.4.4: a word of this
// array is a single 8-bit element.

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
