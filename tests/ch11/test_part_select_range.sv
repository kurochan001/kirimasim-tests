/*
:name: test_part_select_range
:description: Constant and indexed part-selects of a 32-bit vector
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_part_select_range.expected
*/
// Constant and indexed part-selects of a 32-bit vector
// IEEE 1800-2023 Section 11.5.1 - Part-select kinds

module test_part_select_range;
  logic [31:0] data;
  logic [7:0] result1, result2, result3;
  int i;

  initial begin
    data = 32'hDEADBEEF;
    i = 8;

    // Simple part-select [high:low]
    result1 = data[15:8];
    $display("data[15:8] = %h (expected: BE)", result1);
    if (result1 !== 8'hBE) begin
      $display("FAIL: Simple part-select [15:8] incorrect");
      $finish;
    end

    // Indexed up part-select [base+:width]
    result2 = data[8+:8];  // Equivalent to data[15:8]
    $display("data[8+:8] = %h (expected: BE)", result2);
    if (result2 !== 8'hBE) begin
      $display("FAIL: Indexed up part-select [8+:8] incorrect");
      $finish;
    end

    // Indexed down part-select [base-:width]
    result3 = data[15-:8];  // Equivalent to data[15:8]
    $display("data[15-:8] = %h (expected: BE)", result3);
    if (result3 !== 8'hBE) begin
      $display("FAIL: Indexed down part-select [15-:8] incorrect");
      $finish;
    end

    // Dynamic indexed part-select (base from variable)
    result1 = data[i+:8];  // i=8, so data[15:8]
    $display("data[i+:8] with i=%0d = %h (expected: BE)", i, result1);
    if (result1 !== 8'hBE) begin
      $display("FAIL: Dynamic indexed up part-select incorrect");
      $finish;
    end

    // Different position
    result2 = data[0+:8];  // data[7:0]
    $display("data[0+:8] = %h (expected: EF)", result2);
    if (result2 !== 8'hEF) begin
      $display("FAIL: Indexed up part-select [0+:8] incorrect");
      $finish;
    end

    result3 = data[31-:8];  // data[31:24]
    $display("data[31-:8] = %h (expected: DE)", result3);
    if (result3 !== 8'hDE) begin
      $display("FAIL: Indexed down part-select [31-:8] incorrect");
      $finish;
    end

    $display("PASS: All part-select tests passed");
    $finish;
  end
endmodule
