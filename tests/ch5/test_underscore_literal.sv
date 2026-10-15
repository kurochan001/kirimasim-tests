/*
:name: test_underscore_literal
:description: Underscores in binary, hex and decimal literals do not change their values (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_underscore_literal.expected
*/
// IEEE 1800-2023 §5.7.1: an underscore can appear anywhere in a number except
// as its first character, and it does not change the number's value.
`timescale 1ns/1ps

module test_underscore_literal;

  // CORRECT TEST: Same number of digits (21 bits)
  // With underscores: 000001111110011001100 = 21 digits
  logic [21:0] with_underscore = 22'b00_000_1_1_1_1_1_1_0_0_1_1_0_0_1_1_0_0;

  // Without underscores (SAME value - 21 digits)
  logic [21:0] without_underscore = 22'b000001111110011001100;

  // Hex with underscores
  logic [31:0] hex_with_underscore = 32'h1234_5678;
  logic [31:0] hex_without_underscore = 32'h12345678;

  // Decimal with underscores
  logic [31:0] dec_with_underscore = 32'd1_000_000;
  logic [31:0] dec_without_underscore = 32'd1000000;

  int pass_count = 0;
  int fail_count = 0;

  initial begin
    $display("=== Binary Literal Underscore Test ===");

    // Test 1: Binary with underscores
    $display("with_underscore    = %0d (0x%h)", with_underscore, with_underscore);
    $display("without_underscore = %0d (0x%h)", without_underscore, without_underscore);

    if (with_underscore == without_underscore) begin
      $display("PASS: Binary literals match");
      pass_count++;
    end else begin
      $display("FAIL: Binary literals don't match (expected %0d, got %0d)",
               without_underscore, with_underscore);
      fail_count++;
    end

    // Test 2: Hex with underscores
    $display("hex_with_underscore    = 0x%h", hex_with_underscore);
    $display("hex_without_underscore = 0x%h", hex_without_underscore);

    if (hex_with_underscore == hex_without_underscore) begin
      $display("PASS: Hex literals match");
      pass_count++;
    end else begin
      $display("FAIL: Hex literals don't match");
      fail_count++;
    end

    // Test 3: Decimal with underscores
    $display("dec_with_underscore    = %0d", dec_with_underscore);
    $display("dec_without_underscore = %0d", dec_without_underscore);

    if (dec_with_underscore == dec_without_underscore) begin
      $display("PASS: Decimal literals match");
      pass_count++;
    end else begin
      $display("FAIL: Decimal literals don't match");
      fail_count++;
    end

    // Summary
    $display("=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);

    if (fail_count == 0) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end

endmodule
