/*
:name: test_increment_ops
:description: Test increment/decrement operators (IEEE 1800-2023 Section 11.4.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_increment_ops.expected
*/
// Test increment/decrement operators (IEEE 1800-2023 Section 11.4.2)

module test_increment_ops;
  int i, j;
  logic [7:0] byte_val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Pre-increment
    i = 5;
    j = ++i;
    if (i == 6 && j == 6) pass_count++;

    // Test 2: Post-increment
    i = 5;
    j = i++;
    if (i == 6 && j == 5) pass_count++;

    // Test 3: Pre-decrement
    i = 5;
    j = --i;
    if (i == 4 && j == 4) pass_count++;

    // Test 4: Post-decrement
    i = 5;
    j = i--;
    if (i == 4 && j == 5) pass_count++;

    // Test 5: Increment in loop
    j = 0;
    for (i = 0; i < 5; i++) j++;
    if (j == 5) pass_count++;

    // Test 6: Decrement in loop
    j = 10;
    for (i = 5; i > 0; i--) j--;
    if (j == 5) pass_count++;

    // Test 7: Increment on vector
    byte_val = 8'hFE;
    byte_val++;
    if (byte_val == 8'hFF) pass_count++;

    // Test 8: Overflow on increment
    byte_val = 8'hFF;
    byte_val++;
    if (byte_val == 8'h00) pass_count++;

    $display("Increment ops tests: %0d/8 passed", pass_count);
    if (pass_count == 8) begin
      $display("PASS: Increment ops tests");
    end else begin
      $display("FAIL: Some increment tests failed");
    end
  end
endmodule
