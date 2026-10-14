/*
:name: test_continuous_assign_function
:description: A continuous assignment that calls a function is re-evaluated when the function's inputs change
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_assign_function.expected
*/
// IEEE 1800-2023 §10.3.1: Continuous assignments with function calls
// Expected: Function is re-evaluated when input changes, result propagates to LHS

`timescale 1ns/1ps

module test_continuous_assign_function;
  // Test 1: Simple function returning input value
  logic test_input1;
  logic result1;

  function automatic logic pass_through(input logic value);
    return value;
  endfunction

  assign result1 = pass_through(test_input1);

  logic [7:0] test_input2;
  logic result2;

  function automatic logic check_value(input logic [7:0] value);
    case (value)
      8'h02: return 1'b1;
      8'h04: return 1'b1;
      8'h10: return 1'b1;
      default: return 1'b0;
    endcase
  endfunction

  assign result2 = check_value(test_input2);

  // Test 3: Function with if-else
  logic [7:0] test_input3;
  logic result3;

  function automatic logic check_range(input logic [7:0] value);
    if (value >= 8'h10 && value <= 8'h20)
      return 1'b1;
    else
      return 1'b0;
  endfunction

  assign result3 = check_range(test_input3);

  int pass_count = 0;
  int fail_count = 0;

  initial begin
    $display("=== Continuous Assignment with Function Call Test ===");
    $display("");

    // Test 1: Simple pass-through function
    $display("[Test 1] Simple pass-through function");
    test_input1 = 0;
    #1;
    if (result1 == 0) begin
      $display("  PASS: input=0 -> result=0");
      pass_count++;
    end else begin
      $display("  FAIL: input=0 -> result=%b (expected 0)", result1);
      fail_count++;
    end

    test_input1 = 1;
    #1;
    if (result1 == 1) begin
      $display("  PASS: input=1 -> result=1");
      pass_count++;
    end else begin
      $display("  FAIL: input=1 -> result=%b (expected 1)", result1);
      fail_count++;
    end

    // Test 2: Function with case statement
    $display("");
    $display("[Test 2] Function with case statement");
    test_input2 = 8'h00;
    #1;
    if (result2 == 0) begin
      $display("  PASS: input=0x00 -> result=0 (default case)");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x00 -> result=%b (expected 0)", result2);
      fail_count++;
    end

    test_input2 = 8'h02;
    #1;
    if (result2 == 1) begin
      $display("  PASS: input=0x02 -> result=1");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x02 -> result=%b (expected 1)", result2);
      fail_count++;
    end

    test_input2 = 8'h04;
    #1;
    if (result2 == 1) begin
      $display("  PASS: input=0x04 -> result=1");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x04 -> result=%b (expected 1)", result2);
      fail_count++;
    end

    test_input2 = 8'h10;
    #1;
    if (result2 == 1) begin
      $display("  PASS: input=0x10 -> result=1");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x10 -> result=%b (expected 1)", result2);
      fail_count++;
    end

    test_input2 = 8'hFF;
    #1;
    if (result2 == 0) begin
      $display("  PASS: input=0xFF -> result=0 (default case)");
      pass_count++;
    end else begin
      $display("  FAIL: input=0xFF -> result=%b (expected 0)", result2);
      fail_count++;
    end

    // Test 3: Function with if-else and range check
    $display("");
    $display("[Test 3] Function with if-else range check");
    test_input3 = 8'h00;
    #1;
    if (result3 == 0) begin
      $display("  PASS: input=0x00 -> result=0 (out of range)");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x00 -> result=%b (expected 0)", result3);
      fail_count++;
    end

    test_input3 = 8'h15;
    #1;
    if (result3 == 1) begin
      $display("  PASS: input=0x15 -> result=1 (in range)");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x15 -> result=%b (expected 1)", result3);
      fail_count++;
    end

    test_input3 = 8'h30;
    #1;
    if (result3 == 0) begin
      $display("  PASS: input=0x30 -> result=0 (out of range)");
      pass_count++;
    end else begin
      $display("  FAIL: input=0x30 -> result=%b (expected 0)", result3);
      fail_count++;
    end

    // Summary
    $display("");
    $display("=== Summary ===");
    $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
