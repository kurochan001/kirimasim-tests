/*
:name: test_assoc_delete
:description: Test associative array delete (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_delete.expected
*/
// Test associative array delete (IEEE 1800-2023 Section 7.8)

module test_assoc_delete;
  int aa[string];
  int pass_count;

  initial begin
    pass_count = 0;
    aa["a"] = 1;
    aa["b"] = 2;
    aa["c"] = 3;

    // Test 1: Delete one key
    aa.delete("b");
    if (!aa.exists("b")) pass_count++;

    // Test 2: Others remain
    if (aa.exists("a") && aa.exists("c")) pass_count++;

    // Test 3: Delete all
    aa.delete();
    if (aa.size() == 0) pass_count++;

    $display("Assoc delete tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Assoc delete tests");
    end else begin
      $display("FAIL: Some assoc delete tests failed");
    end
  end
endmodule
