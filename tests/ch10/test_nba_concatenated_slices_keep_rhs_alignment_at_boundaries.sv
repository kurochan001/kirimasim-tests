/*
:name: test_nba_concatenated_slices_keep_rhs_alignment_at_boundaries
:description: A concatenated nonblocking target keeps each half of the right side aligned across clipped and empty slices
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 11.5.1 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_concatenated_slices_keep_rhs_alignment_at_boundaries.expected
*/
`timescale 1ns/1ns
module test_nba_concatenated_slices_keep_rhs_alignment_at_boundaries;
  logic [7:-4] left_bank[2];
  logic [1:12] right_bank[2];
  bit clock;
  logic row_select;
  logic signed [5:0] left_start, right_end;
  logic [7:0] packet;

  always @(posedge clock) begin : schedule_update
    logic row;
    logic signed [5:0] first_pos, second_pos;
    logic [7:0] saved_packet;
    left_bank[0] <= 12'ha54;
    left_bank[1] <= 12'h627;
    right_bank[0] <= 12'hd31;
    right_bank[1] <= 12'h8e6;

    row = row_select;
    first_pos = left_start;
    second_pos = right_end;
    saved_packet = packet;
    {left_bank[row][first_pos+:4], right_bank[!row][second_pos-:4]} <= saved_packet;
    row = !row;
    first_pos = 0;
    second_pos = 4;
    saved_packet = 0;
  end

  task automatic observe(input string label_text, input logic selected,
                         input logic signed [5:0] left_base, right_base,
                         input logic [7:0] value);
    row_select = selected;
    left_start = left_base;
    right_end = right_base;
    packet = value;
    #1 clock = 1;
    #1 $display("%s left=%h/%h right=%h/%h",
                label_text, left_bank[0], left_bank[1], right_bank[0], right_bank[1]);
    clock = 0;
  endtask

  initial begin
    observe("left clipped", 0, -6'sd6, 6'sd8, 8'hd2);
    observe("left absent", 1, -6'sd10, 6'sd15, 8'hf6);
    observe("right absent", 0, 6'sd2, -6'sd1, 8'hab);
    $finish(0);
  end
endmodule
