/*
:name: test_generate_assign
:description: Simple nested generate with continuous assign
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 10.3.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_assign.expected
*/
`timescale 1ns/1ps

module test_generate_assign;
  parameter int SIZE = 2;

  logic [7:0] data[SIZE];

  // Simple nested generate with continuous assign
  generate
    for (genvar i = 0; i < SIZE; i++) begin : gen_loop
      assign data[i] = i * 10;
    end
  endgenerate

  initial begin
    #1;
    $display("data[0] = %0d (expected 0)", data[0]);
    $display("data[1] = %0d (expected 10)", data[1]);

    if (data[0] === 8'bx || data[1] === 8'bx) begin
      $display("FAIL: Values are X - continuous assign not working");
    end else if (data[0] == 0 && data[1] == 10) begin
      $display("PASS: Continuous assign in generate works");
    end else begin
      $display("FAIL: Wrong values");
    end
    $finish;
  end
endmodule
