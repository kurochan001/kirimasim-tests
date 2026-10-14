/*
:name: test_program_reactive
:description: Test for IEEE 1800-2023 Chapter 24: Programs
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 24.4 4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_reactive.expected
*/
// Test for IEEE 1800-2023 Chapter 24: Programs
// Section 24.3: Reactive region scheduling
// Section 24.5: Program control tasks

`timescale 1ns/1ps

module dut(
  input logic clk,
  input logic [7:0] data_in,
  output logic [7:0] data_out,
  input logic valid_in,
  output logic valid_out
);
  always_ff @(posedge clk) begin
    data_out <= data_in;
    valid_out <= valid_in;
  end
endmodule

program test_program_reactive(
  input logic clk,
  output logic [7:0] data_in,
  input logic [7:0] data_out,
  output logic valid_in,
  input logic valid_out
);
  int pass_count;
  int fail_count;

  // Program variables
  logic [7:0] expected_data;
  int transaction_count;

  // Task to send transaction
  task automatic send_transaction(input logic [7:0] data);
    @(posedge clk);
    data_in <= data;
    valid_in <= 1;
    expected_data = data;
    transaction_count++;
  endtask

  // Task to check response
  task automatic check_response();
    @(posedge clk);
    @(posedge clk);  // Wait for pipeline
    if (data_out === expected_data && valid_out === 1'b1) begin
      $display("PASS: Transaction %0d verified (data=%h)", transaction_count, data_out);
      pass_count++;
    end else begin
      $display("FAIL: Transaction %0d (expected=%h, got=%h)", transaction_count, expected_data, data_out);
      fail_count++;
    end
    valid_in <= 0;
  endtask

  initial begin
    pass_count = 0;
    fail_count = 0;
    transaction_count = 0;
    $display("=== IEEE 1800-2023 Chapter 24: Program Block ===");

    // Initialize
    data_in = 0;
    valid_in = 0;

    // Wait for reset
    repeat(3) @(posedge clk);

    // Test 1: Single transaction
    $display("\nTest 1: Single transaction");
    send_transaction(8'hAA);
    check_response();

    // Test 2: Multiple transactions
    $display("\nTest 2: Multiple transactions");
    send_transaction(8'h55);
    check_response();
    send_transaction(8'hF0);
    check_response();

    // Test 3: Back-to-back transactions
    $display("\nTest 3: Back-to-back transactions");
    send_transaction(8'h0F);
    @(posedge clk);
    send_transaction(8'hCC);
    check_response();

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
endprogram

module test_program_reactive_wrapper;
  logic clk;
  logic [7:0] data_in, data_out;
  logic valid_in, valid_out;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // DUT instance
  dut u_dut(
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out),
    .valid_in(valid_in),
    .valid_out(valid_out)
  );

  // Program instance
  test_program_reactive u_test(
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out),
    .valid_in(valid_in),
    .valid_out(valid_out)
  );
endmodule
