/*
:name: test_assoc_last
:description: Test associative array last (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_last.expected
*/
// Test associative array last (IEEE 1800-2023 Section 7.8)

module test_assoc_last;
  int aa[int];
  int key;
  int pass_count;

  initial begin
    pass_count = 0;
    aa[10] = 100;
    aa[20] = 200;
    aa[30] = 300;

    // Test 1: Last key
    if (aa.last(key)) begin
      if (key == 30) pass_count++;
    end

    // Test 2: Value at last
    if (aa[key] == 300) pass_count++;

    // Test 3: Empty check
    aa.delete();
    if (!aa.last(key)) pass_count++;

    $display("Assoc last tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Assoc last tests");
    end else begin
      $display("FAIL: Some assoc last tests failed");
    end
  end
endmodule
