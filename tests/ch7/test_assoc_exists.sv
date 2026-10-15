/*
:name: test_assoc_exists
:description: Test associative array exists (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_exists.expected
*/
// Test associative array exists (IEEE 1800-2023 Section 7.8)

module test_assoc_exists;
  int aa[string];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Non-existent key
    if (!aa.exists("key1")) pass_count++;

    // Test 2: After adding
    aa["key1"] = 42;
    if (aa.exists("key1")) pass_count++;

    // Test 3: Different key
    if (!aa.exists("key2")) pass_count++;

    $display("Assoc exists tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Assoc exists tests");
    end else begin
      $display("FAIL: Some assoc exists tests failed");
    end
  end
endmodule
