/*
:name: test_assert_immed_2
:description: Test immediate assertions (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_immed_2.expected
*/
// Test immediate assertions (IEEE 1800-2023 Section 16.3)

module test_assert_immed;
  logic [7:0] val;
  int pass_count;

  initial begin
    pass_count = 0;
    val = 8'h00;

    // Test 1: Assert true
    assert(1'b1) pass_count++;

    // Test 2: Assert expression
    val = 8'hAA;
    assert(val == 8'hAA) pass_count++;

    // Test 3: Assert with else
    assert(val == 8'hAA) pass_count++;
    else $error("Should not fail");

    // Test 4: Assume
    assume(val == 8'hAA) pass_count++;

    // Test 5: Cover. Its pass statement runs when the expression is true
    // (16.3).
    cover(val == 8'hAA) pass_count++;

    $display("Assert immed tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Assert immed tests");
    end else begin
      $display("FAIL: Some assert tests failed");
    end
  end
endmodule
