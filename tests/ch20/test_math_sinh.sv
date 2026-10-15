/*
:name: test_math_sinh
:description: $sinh function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_math_sinh.expected
*/
// $sinh function
module test_math_sinh;
  real result;
  int pass_count = 0;
  int fail_count = 0;

  initial begin
    // Test 1: sinh(0) = 0
    result = $sinh(0.0);
    if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
      $display("PASS: $sinh(0.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(0.0) = %f, expected 0.0", result);
      fail_count++;
    end

    // Test 2: sinh(1) ≈ 1.175
    result = $sinh(1.0);
    if (result > 1.17 && result < 1.18) begin
      $display("PASS: $sinh(1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(1.0) = %f, expected ~1.175", result);
      fail_count++;
    end

    // Test 3: sinh(-1) ≈ -1.175
    result = $sinh(-1.0);
    if (result > -1.18 && result < -1.17) begin
      $display("PASS: $sinh(-1.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(-1.0) = %f, expected ~-1.175", result);
      fail_count++;
    end

    // Test 4: sinh(2) ≈ 3.627
    result = $sinh(2.0);
    if (result > 3.62 && result < 3.64) begin
      $display("PASS: $sinh(2.0) = %f", result);
      pass_count++;
    end else begin
      $display("FAIL: $sinh(2.0) = %f, expected ~3.627", result);
      fail_count++;
    end

    // Test 5: sinh is odd function: sinh(-x) = -sinh(x)
    result = $sinh(1.5) + $sinh(-1.5);
    if (result > -0.001 && result < 0.001) begin
      $display("PASS: sinh(-x) = -sinh(x) verified");
      pass_count++;
    end else begin
      $display("FAIL: sinh(-x) + sinh(x) = %f, expected ~0", result);
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
