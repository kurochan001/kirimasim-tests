/*
:name: test_nested_net_and_variable_arrays_keep_ordinal_positions
:description: Whole-array copies through a net preserve ordinal positions in both unpacked dimensions and retain all 65 bits
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.4.2 6.22.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nested_net_and_variable_arrays_keep_ordinal_positions.expected
*/
`timescale 1ns/1ns
module test_nested_net_and_variable_arrays_keep_ordinal_positions;
  typedef logic [64:0] word_t;
  word_t source [5:3][9:8];
  wire word_t link [0:2][4:5];
  word_t snapshot [11:9][-2:-1];

  assign link = source;

  task automatic report_rows(input string label_text);
    for (int idx = 0; idx < 3; idx++)
      $display("%s row=%0d link=%h/%h snapshot=%h/%h", label_text, idx, link[idx][4],
               link[idx][5], snapshot[11-idx][-2], snapshot[11-idx][-1]);
  endtask

  initial begin
    source[5][9] = 65'h1_0011223344556677;
    source[5][8] = 65'h0_8899aabbccddeeff;
    source[4][9] = 65'h0_1020304050607080;
    source[4][8] = 65'h1_11223344556677xz;
    source[3][9] = 65'h1_zedcba9876543210;
    source[3][8] = 65'h0_99aa55cc33ee11ff;
    #1;
    snapshot = link;
    report_rows("copied");

    source[4][8] = 65'h0_123456789abcdef0;
    source[3][9] = 65'h1_3487x29c11335599;
    #1 report_rows("live");
    snapshot = link;
    report_rows("recopied");
    $finish(0);
  end
endmodule
