/*
:name: test_readmemh_addresses_comments
:description: $readmemh and $readmemb with comments, @ addresses, x and z digits, underscores, start and finish addresses, and a 2-state target (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4 21.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_readmemh_addresses_comments.expected
*/
// IEEE 1800-2023 §21.4: the file read by $readmemh holds hexadecimal numbers
// separated by white space or comments; x, z and _ may be used as in source
// text. Each number goes to the next element. @ followed by a hexadecimal
// address moves loading to that address; elements that are not loaded keep
// their values. With a start and a finish address, loading runs from the start
// toward the finish, downward if the finish is the lower one. §21.4.2: for a
// 2-state element type, x and z digits load as 0. The test creates its files
// in the current directory.

module test_readmemh_addresses_comments;
  logic [7:0] mem [0:7];
  logic [7:0] dmem [0:7];
  bit   [3:0] bmem [0:1];
  int fd;

  initial begin
    fd = $fopen("test_readmemh_addresses_comments_a.mem", "w");
    $fdisplay(fd, "// two words, then a block comment");
    $fdisplay(fd, "0a 0B /* skipped */ c_c");
    $fdisplay(fd, "@6");
    $fdisplay(fd, "1f x5");
    $fclose(fd);
    foreach (mem[i]) mem[i] = 8'hEE;
    $readmemh("test_readmemh_addresses_comments_a.mem", mem);
    foreach (mem[i]) $display("mem[%0d] = %h", i, mem[i]);

    fd = $fopen("test_readmemh_addresses_comments_b.mem", "w");
    $fdisplay(fd, "aa bb zz");
    $fclose(fd);
    foreach (dmem[i]) dmem[i] = 8'h00;
    $readmemh("test_readmemh_addresses_comments_b.mem", dmem, 7, 5);
    $display("dmem[7:4] = %h %h %h %h", dmem[7], dmem[6], dmem[5], dmem[4]);

    fd = $fopen("test_readmemh_addresses_comments_c.mem", "w");
    $fdisplay(fd, "1x01 0z11");
    $fclose(fd);
    $readmemb("test_readmemh_addresses_comments_c.mem", bmem);
    $display("bmem = %b %b", bmem[0], bmem[1]);
  end
endmodule
