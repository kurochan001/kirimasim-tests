/*
:name: test_sampled_function
:description: Sampled Value Functions Test
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_function.expected
*/
// IEEE 1800-2023 §16.9.3.1 Sampled Value Functions Test
// Tests: $sampled() function for assertion sampling
//
// Per IEEE 1800-2023 §16.9.3.1:
// $sampled(expression) returns the value of expression in the Preponed region.
// The Preponed region is the first region of a time slot, where signals
// are sampled for use in assertions.

module test_sampled_function;
  logic clk = 0;
  logic [7:0] data;
  int errors = 0;

  always #5 clk = ~clk;

  // Test $sampled() using immediate assertions after each posedge
  // This verifies that $sampled returns the preponed value correctly
  initial begin
    data = 8'h00;

    // 1st posedge: preponed data should be 0x00
    @(posedge clk);
    if ($sampled(data) !== 8'h00) begin
      $display("ERROR: Test 1 - $sampled(data)=%h, expected 0x00", $sampled(data));
      errors++;
    end else begin
      $display("OK: Test 1 - $sampled(data)=%h as expected", $sampled(data));
    end
    data = 8'hAA;  // Change data for next test

    // 2nd posedge: preponed data should be 0xAA (value set after 1st posedge)
    @(posedge clk);
    if ($sampled(data) !== 8'hAA) begin
      $display("ERROR: Test 2 - $sampled(data)=%h, expected 0xAA", $sampled(data));
      errors++;
    end else begin
      $display("OK: Test 2 - $sampled(data)=%h as expected", $sampled(data));
    end
    data = 8'hBB;

    // 3rd posedge: preponed data should be 0xBB
    @(posedge clk);
    if ($sampled(data) !== 8'hBB) begin
      $display("ERROR: Test 3 - $sampled(data)=%h, expected 0xBB", $sampled(data));
      errors++;
    end else begin
      $display("OK: Test 3 - $sampled(data)=%h as expected", $sampled(data));
    end
    data = 8'hCC;

    // 4th posedge: preponed data should be 0xCC
    @(posedge clk);
    if ($sampled(data) !== 8'hCC) begin
      $display("ERROR: Test 4 - $sampled(data)=%h, expected 0xCC", $sampled(data));
      errors++;
    end else begin
      $display("OK: Test 4 - $sampled(data)=%h as expected", $sampled(data));
    end

    // Final check
    if (errors == 0) begin
      $display("PASS: $sampled function test completed - all 4 tests passed");
    end else begin
      $display("FAIL: $sampled function test had %0d errors", errors);
    end
    $finish;
  end
endmodule
