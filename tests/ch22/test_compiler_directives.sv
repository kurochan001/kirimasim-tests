/*
:name: test_compiler_directives
:description: Test for IEEE 1800-2023 Chapter 22: Compiler directives
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6 22.7 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compiler_directives.expected
*/
// Test for IEEE 1800-2023 Chapter 22: Compiler directives
// Section 22.3: `ifdef, `ifndef, `else, `elsif, `endif
// Section 22.6: `timescale
// Section 22.7: `default_nettype

`default_nettype wire

`define MY_MACRO 1
`define DATA_WIDTH 8
`define FEATURE_A

// Test timescale directive
`timescale 1ns/1ps

module test_compiler_directives;
  int pass_count;
  int fail_count;

  // Test conditional compilation
`ifdef MY_MACRO
  logic [`DATA_WIDTH-1:0] data_with_macro;
`else
  logic [31:0] data_with_macro;
`endif

`ifdef UNDEFINED_MACRO
  logic undefined_path = 1;
`else
  logic defined_path = 1;
`endif

`ifndef FEATURE_A
  logic no_feature_a = 1;
`else
  logic has_feature_a = 1;
`endif

  // Nested ifdef
`ifdef MY_MACRO
  `ifdef FEATURE_A
    logic nested_both = 1;
  `else
    logic nested_macro_only = 1;
  `endif
`endif

  // elsif directive
`ifdef UNDEFINED1
  localparam MODE = 1;
`elsif UNDEFINED2
  localparam MODE = 2;
`elsif MY_MACRO
  localparam MODE = 3;
`else
  localparam MODE = 4;
`endif

  initial begin
    pass_count = 0;
    fail_count = 0;
    $display("=== IEEE 1800-2023 Chapter 22: Compiler Directives ===");

    // Test 1: `define and parameter width
    data_with_macro = 8'hFF;
    if ($bits(data_with_macro) == `DATA_WIDTH) begin
      $display("PASS: Test 1 - `define DATA_WIDTH = %0d bits", $bits(data_with_macro));
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - `define DATA_WIDTH expected %0d, got %0d", `DATA_WIDTH, $bits(data_with_macro));
      fail_count++;
    end

    // Test 2: `ifdef path selection
    if (defined_path == 1) begin
      $display("PASS: Test 2 - `ifdef selected else path for undefined macro");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - `ifdef path selection");
      fail_count++;
    end

    // Test 3: `ifndef path selection
    if (has_feature_a == 1) begin
      $display("PASS: Test 3 - `ifndef selected else path for defined macro");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - `ifndef path selection");
      fail_count++;
    end

    // Test 4: Nested `ifdef
    if (nested_both == 1) begin
      $display("PASS: Test 4 - Nested `ifdef both conditions true");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Nested `ifdef");
      fail_count++;
    end

    // Test 5: `elsif chain
    if (MODE == 3) begin
      $display("PASS: Test 5 - `elsif selected correct branch (MODE=%0d)", MODE);
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - `elsif expected MODE=3, got %0d", MODE);
      fail_count++;
    end

    // Test 6: Timescale verification
    begin
      realtime t1, t2;
      t1 = $realtime;
      #1.001;  // Should be 1.001ns
      t2 = $realtime;
      if ((t2 - t1) >= 1.0 && (t2 - t1) <= 1.002) begin
        $display("PASS: Test 6 - Timescale 1ns/1ps working (delta=%.3f)", t2-t1);
        pass_count++;
      end else begin
        $display("FAIL: Test 6 - Timescale verification (delta=%.3f)", t2-t1);
        fail_count++;
      end
    end

    // Summary
    $display("");
    $display("=== Test Summary ===");
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);

    if (fail_count == 0) begin
      $display("ALL TESTS PASSED");
    end else begin
      $display("SOME TESTS FAILED");
    end

    $finish;
  end
endmodule
