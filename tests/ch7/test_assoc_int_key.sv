/*
:name: test_assoc_int_key
:description: Test associative array with int key (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_int_key.expected
*/
// Test associative array with int key (IEEE 1800-2023 Section 7.8)

module test_assoc_int_key;
  int aa[int];
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Add element
    aa[100] = 42;
    if (aa[100] == 42) pass_count++;

    // Test 2: Check size
    aa[200] = 84;
    if (aa.size() == 2) pass_count++;

    // Test 3: Check exists
    if (aa.exists(100)) pass_count++;

    // Test 4: Delete element
    aa.delete(100);
    if (!aa.exists(100)) pass_count++;

    $display("Assoc int key tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Assoc int key tests");
    end else begin
      $display("FAIL: Some assoc array tests failed");
    end
  end
endmodule
