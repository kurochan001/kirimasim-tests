/*
:name: test_array_or
:description: Test for array or reduction method
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_or.expected
*/
// Test for array or reduction method
module test_array_or;
  logic [7:0] arr1[] = '{8'h00, 8'h00, 8'h00};
  logic [7:0] arr2[] = '{8'hF0, 8'h0F, 8'h00};
  logic [7:0] arr3[] = '{8'hAA, 8'h55};
  logic [7:0] arr4[];
  logic [7:0] arr5[] = '{8'hCD};
  logic [7:0] result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: OR of all 0s = 00
    result = arr1.or();
    if (result == 8'h00) begin
      $display("PASS: arr1.or() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr1.or() = 0x%02X, expected 0x00", result);
      fail_count++;
    end

    // Test 2: F0 | 0F | 00 = FF
    result = arr2.or();
    if (result == 8'hFF) begin
      $display("PASS: arr2.or() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr2.or() = 0x%02X, expected 0xFF", result);
      fail_count++;
    end

    // Test 3: AA | 55 = FF
    result = arr3.or();
    if (result == 8'hFF) begin
      $display("PASS: arr3.or() = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: arr3.or() = 0x%02X, expected 0xFF", result);
      fail_count++;
    end

    // The standard does not give the result for an empty array (7.12.3), so it is not checked

    // Test 5: OR of single element = element
    result = arr5.or();
    if (result == 8'hCD) begin
      $display("PASS: single element or = 0x%02X", result);
      pass_count++;
    end else begin
      $display("FAIL: single element or = 0x%02X, expected 0xCD", result);
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
