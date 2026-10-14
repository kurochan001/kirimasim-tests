/*
:name: test_dynamic_array_ops
:description: Test for dynamic array operations (IEEE 1800-2023 §7.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_ops.expected
*/
// Test for dynamic array operations (IEEE 1800-2023 §7.5)

module test_dynamic_array_ops;
  int darr[];
  int passed;

  initial begin
    passed = 0;

    // Test 1: Create dynamic array
    $display("Test 1: Create dynamic array");
    darr = new[5];
    if (darr.size() == 5) begin
      $display("  PASS: size = %0d", darr.size());
      passed++;
    end else begin
      $display("  FAIL: size = %0d", darr.size());
    end

    // Test 2: Initialize elements
    $display("Test 2: Initialize elements");
    for (int i = 0; i < 5; i++) begin
      darr[i] = (i + 1) * 10;
    end
    if (darr[0] == 10 && darr[4] == 50) begin
      $display("  PASS: darr = {%0d,...,%0d}", darr[0], darr[4]);
      passed++;
    end else begin
      $display("  FAIL");
    end

    // Test 3: Resize larger
    $display("Test 3: Resize larger");
    darr = new[8](darr);  // Copy and extend
    if (darr.size() == 8 && darr[0] == 10 && darr[4] == 50) begin
      $display("  PASS: resized to %0d, preserved values", darr.size());
      passed++;
    end else begin
      $display("  FAIL");
    end

    // Test 4: Resize smaller
    $display("Test 4: Resize smaller");
    darr = new[3](darr);
    if (darr.size() == 3 && darr[2] == 30) begin
      $display("  PASS: resized to %0d", darr.size());
      passed++;
    end else begin
      $display("  FAIL");
    end

    // Test 5: Delete
    $display("Test 5: Delete array");
    darr.delete();
    if (darr.size() == 0) begin
      $display("  PASS: deleted, size = %0d", darr.size());
      passed++;
    end else begin
      $display("  FAIL: size = %0d", darr.size());
    end

    // Test 6: Create with literal
    $display("Test 6: Create with literal");
    darr = '{100, 200, 300};
    if (darr.size() == 3 && darr[1] == 200) begin
      $display("  PASS: literal init, darr[1] = %0d", darr[1]);
      passed++;
    end else begin
      $display("  FAIL");
    end

    if (passed >= 5) begin
      $display("TEST PASSED: %0d/6 tests passed", passed);
    end else begin
      $display("TEST FAILED: Only %0d/6 tests passed", passed);
    end
    $finish;
  end
endmodule
