/*
:name: test_macro_args
:description: Macro arguments edge cases
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_args.expected
*/
// IEEE 1800-2023 §22.5.1: Macro arguments edge cases
`timescale 1ns/1ps

// Simple macro with arguments
`define ADD(a, b) ((a) + (b))

// Macro with default argument (IEEE 1800-2023 §22.5.1)
`define SCALE(x, factor=2) ((x) * (factor))

// Nested macro expansion
`define DOUBLE(x) `ADD(x, x)

// Macro with empty argument handling
`define MAYBE(cond, val, default) ((cond) ? (val) : (default))

// String concatenation macro
`define CONCAT(a, b) `"a``b`"

module test_macro_args;
  int a, b, c, d;
  string s;

  initial begin
    // Test 1: Basic macro with arguments
    a = `ADD(3, 4);
    if (a != 7) begin
      $display("FAIL: ADD(3,4) expected 7, got %0d", a);
      $finish;
    end

    // Test 2: Nested expressions in macro args
    b = `ADD(`ADD(1, 2), `ADD(3, 4));
    if (b != 10) begin
      $display("FAIL: Nested ADD expected 10, got %0d", b);
      $finish;
    end

    // Test 3: Default argument
    c = `SCALE(5);
    if (c != 10) begin
      $display("FAIL: SCALE(5) with default expected 10, got %0d", c);
      $finish;
    end

    // Test 4: Override default argument
    d = `SCALE(5, 3);
    if (d != 15) begin
      $display("FAIL: SCALE(5,3) expected 15, got %0d", d);
      $finish;
    end

    // Test 5: Nested macro
    a = `DOUBLE(7);
    if (a != 14) begin
      $display("FAIL: DOUBLE(7) expected 14, got %0d", a);
      $finish;
    end

    // Test 6: Conditional macro
    b = `MAYBE(1, 100, 200);
    c = `MAYBE(0, 100, 200);
    if (b != 100 || c != 200) begin
      $display("FAIL: MAYBE conditional failed");
      $finish;
    end

    $display("PASS: Macro arguments edge cases");
    $finish;
  end
endmodule
