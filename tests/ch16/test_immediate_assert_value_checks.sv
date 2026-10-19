/*
:name: test_immediate_assert_value_checks
:description: Immediate assertions on the value and range of a variable, counting failures
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assert_value_checks.expected
*/
module tb;
  int failure_count = 0;
  int test_val = 10;

  initial begin
    assert (test_val == 10) else begin
      $display("ASSERTION FAIL: extended test 10 time=%0d", $time);
      failure_count++;
    end

    assert (test_val > 0) else begin
      $display("ASSERTION FAIL: positive check 10 time=%0d", $time);
      failure_count++;
    end

    assert (test_val < 1000) else begin
      $display("ASSERTION FAIL: range check 10 time=%0d", $time);
      failure_count++;
    end

    #1; // Small delay to ensure all assertions are processed

    $display("FAILURE_COUNT=%0d", failure_count);

    if (failure_count == 0) begin
      $display("Immediate assertion test completed successfully!");
      $display("PASS");
    end else begin
      $display("Test failed with %0d assertion failures", failure_count);
    end

    $finish;
  end
endmodule
