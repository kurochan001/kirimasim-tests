/*
:name: test_nba_array_struct_slices_capture_row_base_and_value
:description: Scheduled writes through an array row and a struct member capture both indices and the replacement value
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 11.5.1 7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_array_struct_slices_capture_row_base_and_value.expected
*/
`timescale 1ns/1ns
module scheduled_struct_banks(input logic clock, input logic [70:0] seed_zero, seed_one,
                              input logic starting_row,
                              input logic signed [7:0] left_base, right_base,
                              input logic [7:0] first_data, second_data,
                              output logic [77:0] bank_zero, bank_one);
  typedef struct packed {
    logic [6:0] tag_bits;
    logic [58:-12] content;
  } bank_t;
  bank_t banks[2];

  assign bank_zero = banks[0];
  assign bank_one = banks[1];

  always @(posedge clock) begin : schedule_both
    logic row;
    logic signed [7:0] position;
    logic [7:0] replacement;

    banks[0] <= {7'h2e, seed_zero};
    banks[1] <= {7'h65, seed_one};
    row = starting_row;
    position = left_base;
    replacement = first_data;
    banks[row].content[position+:8] <= replacement;
    row = !row;
    position = right_base;
    replacement = second_data;
    banks[row].content[position-:8] <= replacement;
    row = 0;
    position = 0;
    replacement = 0;
  end

`ifdef FORMAL
  function automatic logic [70:0] updated(
    input logic [70:0] seed, input int low, input logic [7:0] data
  );
    updated = seed;
    for (int offset = 0; offset < 71; offset++) begin
      if (offset - 12 >= low && offset - 12 < low + 8)
        updated[offset] = data[offset - 12 - low];
    end
  endfunction

  logic ready = 0;
  logic [77:0] expected_zero, expected_one;
  always @(posedge clock) begin
    if (ready) begin
      assert (bank_zero == expected_zero);
      assert (bank_one == expected_one);
    end
    ready <= 1;
    if (starting_row) begin
      expected_zero <= {7'h2e, updated(seed_zero, int'(right_base)-7, second_data)};
      expected_one <= {7'h65, updated(seed_one, int'(left_base), first_data)};
    end else begin
      expected_zero <= {7'h2e, updated(seed_zero, int'(left_base), first_data)};
      expected_one <= {7'h65, updated(seed_one, int'(right_base)-7, second_data)};
    end
  end
`endif
endmodule

`ifndef FORMAL
module test_nba_array_struct_slices_capture_row_base_and_value;
  logic clock, starting_row;
  logic [70:0] seed_zero = 71'h5123456789abcdef01;
  logic [70:0] seed_one = 71'h2e9876543210fedcba;
  logic signed [7:0] left_base, right_base;
  logic [7:0] first_data, second_data;
  wire [77:0] bank_zero, bank_one;

  scheduled_struct_banks dut(clock, seed_zero, seed_one, starting_row, left_base, right_base,
                             first_data, second_data, bank_zero, bank_one);

  task automatic observe(input string label_text, input bit row,
                         input logic signed [7:0] one_base, other_base,
                         input logic [7:0] one_data, other_data);
    starting_row = row;
    left_base = one_base;
    right_base = other_base;
    first_data = one_data;
    second_data = other_data;
    #1 clock = 1;
    #1 $display("%s bank0=%h/%h bank1=%h/%h", label_text, bank_zero[77:71], bank_zero[70:0],
                bank_one[77:71], bank_one[70:0]);
    clock = 0;
  endtask

  initial begin
    clock = 0;
    observe("clipped", 0, -8'sd17, 8'sd63, 8'hf3, 8'h6d);
    observe("reversed", 1, 8'sd10, 8'sd17, 8'hbe, 8'h35);
    observe("outside", 0, -8'sd30, 8'sd72, 8'hff, 8'h00);
    $finish(0);
  end
endmodule
`endif
