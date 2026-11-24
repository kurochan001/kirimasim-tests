/*
:name: test_wide_indexed_part_select_clips_nonzero_bounds
:description: Wide indexed part-select writes clip both ends of ascending and descending packed ranges with negative bounds
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wide_indexed_part_select_clips_nonzero_bounds.expected
*/
`timescale 1ns/1ns
module wide_clip_writer(input logic [96:0] seed, input logic [8:0] bits_to_write,
                        input logic signed [8:0] base,
                        output logic [81:-15] down_plus, down_minus,
                        output logic [-15:81] up_plus, up_minus);
  always_comb begin
    down_plus = seed;
    down_minus = seed;
    up_plus = seed;
    up_minus = seed;
    down_plus[base+:9] = bits_to_write;
    down_minus[base-:9] = bits_to_write;
    up_plus[base+:9] = bits_to_write;
    up_minus[base-:9] = bits_to_write;
  end

`ifdef FORMAL
  logic [81:-15] reference_down_plus, reference_down_minus;
  logic [-15:81] reference_up_plus, reference_up_minus;

  always_comb begin
    int expanded_base, plus_distance, minus_distance;
    expanded_base = int'(base);
    reference_down_plus = seed;
    reference_down_minus = seed;
    reference_up_plus = seed;
    reference_up_minus = seed;
    for (int physical = -15; physical <= 81; physical++) begin
      plus_distance = physical - expanded_base;
      minus_distance = expanded_base - physical;
      if (plus_distance >= 0 && plus_distance < 9) begin
        reference_down_plus[physical] = bits_to_write[plus_distance];
        reference_up_plus[physical] = bits_to_write[8-plus_distance];
      end
      if (minus_distance >= 0 && minus_distance < 9) begin
        reference_down_minus[physical] = bits_to_write[8-minus_distance];
        reference_up_minus[physical] = bits_to_write[minus_distance];
      end
    end
    assert (down_plus == reference_down_plus);
    assert (down_minus == reference_down_minus);
    assert (up_plus == reference_up_plus);
    assert (up_minus == reference_up_minus);
  end
`endif
endmodule

`ifndef FORMAL
module test_wide_indexed_part_select_clips_nonzero_bounds;
  localparam logic [96:0] SEED = 97'h1_1234_5678_9abc_def0_1020_3040;
  logic signed [8:0] base;
  wire [81:-15] down_plus, down_minus;
  wire [-15:81] up_plus, up_minus;
  wide_clip_writer dut(SEED, 9'h169, base, down_plus, down_minus, up_plus, up_minus);

  task automatic sample(input int coordinate);
    base = 9'(coordinate);
    #1;
    $display("%0d down=%h/%h up=%h/%h",
             coordinate, down_plus, down_minus, up_plus, up_minus);
  endtask

  initial begin
    sample(-33);
    sample(-23);
    sample(-20);
    sample(-15);
    sample(-7);
    sample(77);
    sample(81);
    sample(85);
    sample(98);
    $finish(0);
  end
endmodule
`endif
