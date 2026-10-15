/*
:name: test_generate_nested
:description: Generate constructs edge cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_nested.expected
*/
// IEEE 1800-2023 §27.3: Generate constructs edge cases
`timescale 1ns/1ps

module test_generate_nested;
  parameter int SIZE = 4;
  parameter int MODE = 2;

  int data[SIZE];
  int result;
  bit test_passed;

  // Generate with if-else
  generate
    if (SIZE > 2) begin : large_size
      localparam int EXTRA = 100;
    end else begin : small_size
      localparam int EXTRA = 10;
    end
  endgenerate

  // Generate with case construct
  generate
    case (MODE)
      0: begin : mode_zero
        localparam int MODE_VAL = 0;
      end
      1: begin : mode_one
        localparam int MODE_VAL = 1;
      end
      2: begin : mode_two
        localparam int MODE_VAL = 2;
      end
      default: begin : mode_default
        localparam int MODE_VAL = -1;
      end
    endcase
  endgenerate

  // Simple generate for loop
  generate
    for (genvar i = 0; i < SIZE; i++) begin : gen_loop
      localparam int LOOP_VAL = i * 10;
    end
  endgenerate

  initial begin
    test_passed = 1;
    result = 0;

    // Test 1: Verify SIZE parameter
    if (SIZE != 4) begin
      $display("FAIL: SIZE should be 4");
      test_passed = 0;
    end

    // Test 2: Verify MODE parameter
    if (MODE != 2) begin
      $display("FAIL: MODE should be 2");
      test_passed = 0;
    end

    // Test 3: Verify generate if selected correct branch
    // SIZE > 2, so large_size block should be active
    result = large_size.EXTRA;
    if (result != 100) begin
      $display("FAIL: large_size.EXTRA should be 100, got %0d", result);
      test_passed = 0;
    end

    // Test 4: Verify generate case selected correct branch
    // MODE == 2, so mode_two block should be active
    result = mode_two.MODE_VAL;
    if (result != 2) begin
      $display("FAIL: mode_two.MODE_VAL should be 2, got %0d", result);
      test_passed = 0;
    end

    // Test 5: Verify generate for loop localparams
    result = gen_loop[0].LOOP_VAL;
    if (result != 0) begin
      $display("FAIL: gen_loop[0].LOOP_VAL should be 0, got %0d", result);
      test_passed = 0;
    end

    result = gen_loop[2].LOOP_VAL;
    if (result != 20) begin
      $display("FAIL: gen_loop[2].LOOP_VAL should be 20, got %0d", result);
      test_passed = 0;
    end

    result = gen_loop[3].LOOP_VAL;
    if (result != 30) begin
      $display("FAIL: gen_loop[3].LOOP_VAL should be 30, got %0d", result);
      test_passed = 0;
    end

    // Test 6: Manually set and verify array
    for (int i = 0; i < SIZE; i++) begin
      data[i] = i * 5;
    end

    result = 0;
    for (int i = 0; i < SIZE; i++) begin
      result += data[i];
    end

    // Sum: 0 + 5 + 10 + 15 = 30
    if (result != 30) begin
      $display("FAIL: Sum should be 30, got %0d", result);
      test_passed = 0;
    end

    if (test_passed) begin
      $display("PASS: Generate constructs edge cases");
    end else begin
      $display("FAIL: Some generate tests failed");
    end
    $finish;
  end
endmodule
