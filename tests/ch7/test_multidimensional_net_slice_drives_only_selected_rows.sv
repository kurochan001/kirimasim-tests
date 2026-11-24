/*
:name: test_multidimensional_net_slice_drives_only_selected_rows
:description: A multidimensional net slice copies selected rows from different bounds without driving the neighboring row
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 7.4.6 6.22.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_multidimensional_net_slice_drives_only_selected_rows.expected
*/
`timescale 1ns/1ns
module test_multidimensional_net_slice_drives_only_selected_rows;
  logic [7:0] source [1:4][-1:0];
  wire [7:0] bus [7:5][3:2];
  logic [7:0] observed [0:1][8:9];

  assign bus[7:6] = source[2:3];

  task automatic sample(input string label_text);
    observed = bus[7:6];
    $display("%s net=%h/%h %h/%h", label_text, bus[7][3], bus[7][2], bus[6][3], bus[6][2]);
    $display("%s chosen=%h/%h %h/%h neighbor=%h/%h", label_text,
             observed[0][8], observed[0][9], observed[1][8], observed[1][9],
             bus[5][3], bus[5][2]);
  endtask

  initial begin
    source[1] = '{8'h11, 8'h12};
    source[2] = '{8'h21, 8'h2z};
    source[3] = '{8'h31, 8'h3x};
    source[4] = '{8'h41, 8'h42};
    #1 sample("initial");
    source[2][0] = 8'h29;
    source[3][-1] = 8'h38;
    source[1] = '{8'h17, 8'h18};
    source[4] = '{8'h47, 8'h48};
    #1 sample("changed");
    $finish(0);
  end
endmodule
