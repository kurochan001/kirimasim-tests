/*
:name: test_generate_blocks
:description: Test generate blocks (IEEE 1800-2023 Section 27)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 23.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_blocks.expected
*/
// Test generate blocks (IEEE 1800-2023 Section 27)

module sub_mod #(parameter int WIDTH = 8) (
  input logic [WIDTH-1:0] in_data,
  output logic [WIDTH-1:0] out_data
);
  assign out_data = in_data + 1;
endmodule

module test_generate_blocks;
  logic [7:0] data_in, data_out;
  logic [15:0] wide_in, wide_out;
  int pass_count;

  // Generate if
  parameter USE_WIDE = 0;
  
  generate
    if (USE_WIDE == 1) begin : gen_wide
      sub_mod #(.WIDTH(16)) u_sub (.in_data(wide_in), .out_data(wide_out));
    end else begin : gen_narrow
      sub_mod #(.WIDTH(8)) u_sub (.in_data(data_in), .out_data(data_out));
    end
  endgenerate

  initial begin
    pass_count = 0;

    // Test 1: Generated module works
    data_in = 8'h10;
    #1;
    if (data_out == 8'h11) pass_count++;

    // Test 2: Different input
    data_in = 8'hFF;
    #1;
    if (data_out == 8'h00) pass_count++;  // Overflow

    // Test 3: Zero input
    data_in = 8'h00;
    #1;
    if (data_out == 8'h01) pass_count++;

    $display("Generate block tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Generate block tests");
    end else begin
      $display("FAIL: Some generate tests failed");
    end
  end
endmodule
