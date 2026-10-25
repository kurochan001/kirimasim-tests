/*
:name: test_readmemh_incomplete_multidim
:description: $readmemh with a file without @ addresses fills a multidimensional unpacked array word by word in row-major order and, when the data run out, stops at the last word it filled and leaves the remaining words and subwords unchanged (IEEE 1800-2023 Section 21.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemh_incomplete_multidim.expected
*/
// IEEE 1800-2023 §21.4.3: for a file without address entries, the data are
// read as if every dimension had complete data, each word of each dimension
// in turn, in row-major order; if the file is incomplete, the read stops at
// the last word it initialized and the remaining words and subwords are left
// unchanged. A [0:1][0:2] array gets 4 values, so m[1][1] and m[1][2] keep
// ee; a [0:1][0:1][0:1] array gets 5 values, so q[1][0][1] and the whole of
// q[1][1] keep e. The files are created in the current directory.

module test_readmemh_incomplete_multidim;
  logic [7:0] m [0:1][0:2];
  logic [3:0] q [0:1][0:1][0:1];
  int fd;

  initial begin
    foreach (m[i, j]) m[i][j] = 8'hee;
    foreach (q[i, j, k]) q[i][j][k] = 4'he;
    fd = $fopen("test_readmemh_incomplete_multidim_m.mem", "w");
    $fdisplay(fd, "10 11 12 20");
    $fclose(fd);
    fd = $fopen("test_readmemh_incomplete_multidim_q.mem", "w");
    $fdisplay(fd, "1 2 3 4 5");
    $fclose(fd);
    $readmemh("test_readmemh_incomplete_multidim_m.mem", m);
    $readmemh("test_readmemh_incomplete_multidim_q.mem", q);
    $display("m[0] = %h %h %h, m[1] = %h %h %h", m[0][0], m[0][1], m[0][2], m[1][0], m[1][1],
             m[1][2]);
    $display("q[0] = %h %h %h %h, q[1] = %h %h %h %h", q[0][0][0], q[0][0][1], q[0][1][0],
             q[0][1][1], q[1][0][0], q[1][0][1], q[1][1][0], q[1][1][1]);
  end
endmodule
