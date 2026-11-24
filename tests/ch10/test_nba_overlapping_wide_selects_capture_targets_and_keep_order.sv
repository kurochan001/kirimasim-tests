/*
:name: test_nba_overlapping_wide_selects_capture_targets_and_keep_order
:description: Overlapping nonblocking part-select writes capture separate bases and values and follow order within one process
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 4.6 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_overlapping_wide_selects_capture_targets_and_keep_order.expected
*/
`timescale 1ns/1ns
module overlapping_nba_writer(input logic clock, input logic [96:0] seed,
                              input logic signed [8:0] start_pos, end_pos,
                              input logic [8:0] first_value, second_value,
                              output logic [81:-15] forward_result, reverse_result);
  always @(posedge clock) begin : write_packet
    logic signed [8:0] selected;
    logic [8:0] value_to_write;
    forward_result <= seed;
    selected = start_pos;
    value_to_write = first_value;
    forward_result[selected+:9] <= value_to_write;
    reverse_result[selected+:9] <= value_to_write;
    selected = end_pos;
    value_to_write = second_value;
    forward_result[selected-:9] <= value_to_write;
    reverse_result[selected-:9] <= value_to_write;
    reverse_result <= seed;
    selected = -256;
    value_to_write = 0;
  end

`ifdef FORMAL
  logic initialized = 0;
  logic [81:-15] expected_now, expected_forward, expected_reverse;
  always_comb begin
    int base_start, base_end, from_first, from_last;
    base_start = int'(start_pos);
    base_end = int'(end_pos);
    expected_now = seed;
    for (int physical = -15; physical <= 81; physical++) begin
      from_first = physical - base_start;
      from_last = base_end - physical;
      if (from_first >= 0 && from_first < 9)
        expected_now[physical] = first_value[from_first];
      if (from_last >= 0 && from_last < 9)
        expected_now[physical] = second_value[8-from_last];
    end
  end

  always @(posedge clock) begin
    initialized <= 1;
    expected_forward <= expected_now;
    expected_reverse <= seed;
    if (initialized) begin
      assert (forward_result == expected_forward);
      assert (reverse_result == expected_reverse);
    end
  end
`endif
endmodule

`ifndef FORMAL
module test_nba_overlapping_wide_selects_capture_targets_and_keep_order;
  bit clock;
  logic [96:0] seed;
  logic signed [8:0] start_pos, end_pos;
  logic [8:0] first_value, second_value;
  wire [81:-15] forward_result, reverse_result;
  overlapping_nba_writer dut(clock, seed, start_pos, end_pos, first_value,
                             second_value, forward_result, reverse_result);

  task automatic sample(input string label_text, input logic [96:0] next_seed,
                        input logic signed [8:0] first_base, second_base,
                        input logic [8:0] first_chunk, second_chunk);
    seed = next_seed;
    start_pos = first_base;
    end_pos = second_base;
    first_value = first_chunk;
    second_value = second_chunk;
    #1 clock = 1;
    #1 $display("%s forward=%h reverse=%h", label_text, forward_result, reverse_result);
    clock = 0;
  endtask

  initial begin
    sample("lower", 97'h1_1234_5678_9abc_def0_1020_3040, -18, -12, 9'h169, 9'h096);
    sample("upper", 97'h0_aaaa_5555_3388_77dd_01f2_3046, 74, 86, 9'h0d3, 9'h1e4);
    sample("middle", 97'h1_0ace_bdf1_5533_7799_4422_aa11, 15, 19, 9'h07c, 9'h14e);
    $finish(0);
  end
endmodule
`endif
