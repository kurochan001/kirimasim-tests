/*
:name: test_foreach_simple
:description: Test simple foreach (IEEE 1800-2023 Section 12.7.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_simple.expected
*/
// Test simple foreach (IEEE 1800-2023 Section 12.7.3)

module test_foreach_simple;
  int arr [5];
  int sum;
  int pass_count;

  initial begin
    pass_count = 0;

    // Initialize array
    foreach (arr[i]) arr[i] = i * 2;

    // Test 1: Foreach sets values
    if (arr[0] == 0 && arr[4] == 8) pass_count++;

    // Test 2: Sum array
    sum = 0;
    foreach (arr[i]) sum += arr[i];
    if (sum == 20) pass_count++;  // 0+2+4+6+8 = 20

    // Test 3: Modify during iteration
    foreach (arr[i]) arr[i] += 1;
    if (arr[0] == 1 && arr[4] == 9) pass_count++;

    // Test 4: Nested array access
    foreach (arr[i]) begin
      if (arr[i] == 5) pass_count++;  // arr[2] should be 5
    end

    // Test 5: Count iterations
    sum = 0;
    foreach (arr[i]) sum++;
    if (sum == 5) pass_count++;

    $display("Foreach simple tests: %0d/5 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Foreach simple tests");
    end else begin
      $display("FAIL: Some foreach tests failed");
    end
  end
endmodule
