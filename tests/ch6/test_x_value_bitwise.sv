/*
:name: test_x_value_bitwise
:description: 4-state logic truth tables
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_x_value_bitwise.expected
*/
// IEEE 1800-2023 Section 6.6.7: 4-state logic truth tables
// X & 0 = 0 (0 is dominant for AND)
// X | 1 = 1 (1 is dominant for OR)

module test_x_value_bitwise;
  logic [3:0] x_val;
  logic [3:0] result_and;
  logic [3:0] result_or;
  int pass_count;
  int fail_count;

  initial begin
    pass_count = 0;
    fail_count = 0;

    // Initialize with X values
    x_val = 4'bxxxx;

    // Test 1: X & 0 should be 0 (IEEE 1800-2023 Section 6.6.7)
    result_and = x_val & 4'b0000;
    if (result_and === 4'b0000) begin
      $display("PASS: X & 0 = 0");
      pass_count++;
    end else begin
      $display("FAIL: X & 0 expected 4'b0000, got %b", result_and);
      fail_count++;
    end

    // Test 2: X | 1 should be 1 (IEEE 1800-2023 Section 6.6.7)
    result_or = x_val | 4'b1111;
    if (result_or === 4'b1111) begin
      $display("PASS: X | 1 = 1");
      pass_count++;
    end else begin
      $display("FAIL: X | 1 expected 4'b1111, got %b", result_or);
      fail_count++;
    end

    // Test 3: Mixed X and known values with AND
    x_val = 4'bxx10;
    result_and = x_val & 4'b1001;
    // xx10 & 1001 = x010 (bit 3: x&1=x, bit 2: x&0=0, bit 1: 1&0=0, bit 0: 0&1=0)
    if (result_and === 4'bx000) begin
      $display("PASS: 4'bxx10 & 4'b1001 = 4'bx000");
      pass_count++;
    end else begin
      $display("FAIL: 4'bxx10 & 4'b1001 expected 4'bx000, got %b", result_and);
      fail_count++;
    end

    // Test 4: Mixed X and known values with OR
    x_val = 4'bxx01;
    result_or = x_val | 4'b0110;
    // xx01 | 0110 = x111 (bit 3: x|0=x, bit 2: x|1=1, bit 1: 0|1=1, bit 0: 1|0=1)
    if (result_or === 4'bx111) begin
      $display("PASS: 4'bxx01 | 4'b0110 = 4'bx111");
      pass_count++;
    end else begin
      $display("FAIL: 4'bxx01 | 4'b0110 expected 4'bx111, got %b", result_or);
      fail_count++;
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
