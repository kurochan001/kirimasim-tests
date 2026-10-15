/*
:name: test_assoc_prev
:description: Test associative array prev (IEEE 1800-2023 Section 7.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_prev.expected
*/
// Test associative array prev (IEEE 1800-2023 Section 7.8)

module test_assoc_prev;
  int aa[int];
  int key;
  int pass_count;

  initial begin
    pass_count = 0;
    aa[10] = 100;
    aa[20] = 200;
    aa[30] = 300;

    // Test 1: Get last then prev
    void'(aa.last(key));
    if (aa.prev(key)) begin
      if (key == 20) pass_count++;
    end

    // Test 2: Prev again
    if (aa.prev(key)) begin
      if (key == 10) pass_count++;
    end

    // Test 3: No more prev
    if (!aa.prev(key)) pass_count++;

    $display("Assoc prev tests: %0d/3 passed", pass_count);
    if (pass_count == 3) begin
      $display("PASS: Assoc prev tests");
    end else begin
      $display("FAIL: Some assoc prev tests failed");
    end
  end
endmodule
