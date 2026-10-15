/*
:name: test_array_xor
:description: Test for array xor reduction method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_xor.expected
*/
// Test for array xor reduction method
module test_array_xor;
  logic [7:0] arr1[] = '{8'hFF, 8'hFF};
  logic [7:0] arr2[] = '{8'hAA, 8'h55};
  logic [7:0] arr3[] = '{8'h12, 8'h34, 8'h56};
  logic [7:0] arr4[];
  logic [7:0] arr5[] = '{8'hEF};
  logic [7:0] result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: FF ^ FF = 00
    result = arr1.xor();
    if (result == 8'h00) begin
      $display("PASS: arr1.xor() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr1.xor() = 0x%02X, expected 0x00", result);
      fail_count++;
    end

    // Test 2: AA ^ 55 = FF
    result = arr2.xor();
    if (result == 8'hFF) begin
      $display("PASS: arr2.xor() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr2.xor() = 0x%02X, expected 0xFF", result);
      fail_count++;
    end

    // Test 3: 12 ^ 34 ^ 56 = 70
    result = arr3.xor();
    if (result == 8'h70) begin
      $display("PASS: arr3.xor() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr3.xor() = 0x%02X, expected 0x70", result);
      fail_count++;
    end

    // The standard does not give the result for an empty array (7.12.3), so it is not checked

    // Test 5: XOR of single element = element
    result = arr5.xor();
    if (result == 8'hEF) begin
      $display("PASS: single element xor = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: single element xor = 0x%02X, expected 0xEF", result);
      fail_count++;
    end

    // Summary
    $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All tests passed");
    else
      $display("FAIL: Some tests failed");
    $finish;
  end
endmodule
