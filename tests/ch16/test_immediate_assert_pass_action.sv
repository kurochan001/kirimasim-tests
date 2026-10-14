/*
:name: test_immediate_assert_pass_action
:description: Immediate assertions with pass action statements (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assert_pass_action.expected
*/
// Immediate assertions with pass action statements (IEEE 1800-2023 Section 16.3)
module test_immediate_simple;
  int failure_count = 0;

  initial begin
    $display("Starting immediate assertion test");

    // Test 1: Should pass
    assert (1 == 1)
      $display("PASS: Basic equality assertion");
    else begin
      $display("ASSERTION FAIL: Basic equality failed");
      failure_count++;
    end

    // Test 2: Should pass
    assert (10 > 5)
      $display("PASS: Comparison assertion");
    else begin
      $display("ASSERTION FAIL: Comparison failed");
      failure_count++;
    end

    // Test 3: Should pass
    assert (2 + 2 == 4)
      $display("PASS: Arithmetic assertion");
    else begin
      $display("ASSERTION FAIL: Arithmetic failed");
      failure_count++;
    end

    // Report results
    $display("FAILURE_COUNT=%0d", failure_count);
    if (failure_count == 0) begin
      $display("SUCCESS: All immediate assertions passed");
    end
    $finish;
  end
endmodule
