/*
:name: test_generate_assign2
:description: Two-level nested generate loops with continuous assignments to a 2-D array
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_generate_assign2.expected
*/
`timescale 1ns/1ps

module test_generate_assign2;
  parameter int DEPTH = 3;
  parameter int WIDTH = 2;

  logic [31:0] data[DEPTH][WIDTH];

  // 2-level nested generate
  generate
    for (genvar level = 0; level < DEPTH; level++) begin : gen_level
      for (genvar unit = 0; unit < WIDTH; unit++) begin : gen_unit
        assign data[level][unit] = level * 10 + unit;
      end
    end
  endgenerate

  initial begin
    #1;
    for (int l = 0; l < DEPTH; l++) begin
      for (int u = 0; u < WIDTH; u++) begin
        $display("data[%0d][%0d] = %0d (expected %0d)", l, u, data[l][u], l * 10 + u);
      end
    end

    if (data[0][0] === 32'bx) begin
      $display("FAIL: Values are X - 2D array assign not working");
    end else if (data[0][0] == 0 && data[0][1] == 1 && data[1][0] == 10) begin
      $display("PASS: 2D array continuous assign works");
    end else begin
      $display("FAIL: Wrong values");
    end
    $finish;
  end
endmodule
