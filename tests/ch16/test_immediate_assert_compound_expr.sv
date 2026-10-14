/*
:name: test_immediate_assert_compound_expr
:description: Immediate assertions on compound logical and arithmetic expressions, counting failures
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assert_compound_expr.expected
*/
module tb;
  int failure_count = 0;
  int a = 5, b = 10;

  initial begin
    assert ((a < b) && (a + b == 15)) else begin
      $display("ASSERTION FAIL: complex expression time=%0t", $time);
      failure_count++;
    end

    assert ((a * 2) == b) else begin
      $display("ASSERTION FAIL: arithmetic assertion time=%0t", $time);
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
