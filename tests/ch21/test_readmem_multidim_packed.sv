/*
:name: test_readmem_multidim_packed
:description: $readmemh fills a multidimensional unpacked array in row-major order with each dimension running from its low to its high address, an address entry selects a word of the highest dimension and leaves its unfilled subwords unchanged, a word of a memory with several packed dimensions is all their bits, and x digits read into a 2-state type become 0 (IEEE 1800-2023 Sections 21.4.1, 21.4.2, 21.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.3 21.4.1 21.4.2 21.4 7.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_readmem_multidim_packed.expected
*/
// IEEE 1800-2023 §21.4.3: for a multidimensional unpacked array, the words in
// the file are in row-major order, the rightmost dimension varying fastest,
// and each dimension runs from its low to its high address whatever the order
// of its range; an address entry addresses a word of the highest dimension,
// and if the data do not fill it, its remaining subwords are unchanged. A word
// of a memory with several packed dimensions is all their bits (§7.4.4).
// §21.4.1: packed elements are read as vectors. §21.4.2: for 2-state types,
// x and z data become 0. The test writes its files in the current directory.

module test_readmem_multidim_packed;
  logic [7:0] m [0:1][2:0];
  logic [1:0][3:0] p [0:1];
  int w [0:1];
  int fd;

  initial begin
    fd = $fopen("test_readmem_multidim_packed_1.txt", "w");
    $fdisplay(fd, "10 11 12");
    $fdisplay(fd, "20 21 22");
    $fclose(fd);
    $readmemh("test_readmem_multidim_packed_1.txt", m);
    $display("m[0][0..2] = %h %h %h, m[1][0..2] = %h %h %h", m[0][0], m[0][1], m[0][2],
             m[1][0], m[1][1], m[1][2]);

    fd = $fopen("test_readmem_multidim_packed_2.txt", "w");
    $fdisplay(fd, "@1 a0 a1");
    $fclose(fd);
    $readmemh("test_readmem_multidim_packed_2.txt", m);
    $display("after @1: m[0][0..2] = %h %h %h, m[1][0..2] = %h %h %h", m[0][0], m[0][1],
             m[0][2], m[1][0], m[1][1], m[1][2]);

    fd = $fopen("test_readmem_multidim_packed_3.txt", "w");
    $fdisplay(fd, "5a 3c");
    $fclose(fd);
    $readmemh("test_readmem_multidim_packed_3.txt", p);
    $display("p[0] = %h (p[0][1] = %h, p[0][0] = %h), p[1] = %h", p[0], p[0][1], p[0][0], p[1]);

    fd = $fopen("test_readmem_multidim_packed_4.txt", "w");
    $fdisplay(fd, "1x 7");
    $fclose(fd);
    $readmemh("test_readmem_multidim_packed_4.txt", w);
    $display("w = %h %h", w[0], w[1]);
  end
endmodule
