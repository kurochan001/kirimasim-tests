/*
:name: test_assoc_next
:description: Test associative array next (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.4 7.9.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_next.expected
*/
// Test associative array next (IEEE 1800-2023 Section 7.8)

module test_assoc_next;
  int aa[int];
  int key;
  int pass_count;

  initial begin
    pass_count = 0;
    aa[10] = 100;
    aa[20] = 200;
    aa[30] = 300;

    // Test 1: Get first then next
    void'(aa.first(key));
    if (aa.next(key)) begin
      if (key == 20) pass_count++;
    end

    // Test 2: Next again
    if (aa.next(key)) begin
      if (key == 30) pass_count++;
    end

    // Test 3: No more next
    if (!aa.next(key)) pass_count++;

    $display("Assoc next tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Assoc next tests");
    end else begin
      $display("FAIL: Some assoc next tests failed");
    end
  end
endmodule
