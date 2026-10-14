/*
:name: test_generate_scope_hierarchy
:description: Test for generate scope hierarchy (IEEE 1800-2023 §27.4 and §23.6)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_scope_hierarchy.expected
*/
// Test for generate scope hierarchy (IEEE 1800-2023 §27.4 and §23.6)
// Tests nested generate scopes and genvar access in nested blocks

module test_generate_scope_hierarchy;

  parameter int DEPTH1 = 2;
  parameter int DEPTH2 = 3;
  int pass_count = 0;
  int test_count = 0;
  int results[6];  // Store results from generate blocks

  // Level 1 generate
  generate
    genvar i;
    for (i = 0; i < DEPTH1; i = i + 1) begin : level1
      // Nested level 2 generate
      genvar j;
      for (j = 0; j < DEPTH2; j = j + 1) begin : level2
        localparam int COMPUTED = i * 10 + j;
        // Only stores the value: the order of these initial blocks at time 0
        // is not defined, so the results are printed later from one block.
        initial results[i * 3 + j] = COMPUTED;
      end
    end
  endgenerate

  initial begin
    #1;  // Wait for generate initial blocks to execute
    for (int k = 0; k < DEPTH1 * DEPTH2; k++)
      $display("Nested generate: results[%0d] = %0d", k, results[k]);

    // Test 1: Check level1[0].level2[0]
    test_count = test_count + 1;
    if (results[0] == 0) begin
      $display("PASS: results[0] = %0d", results[0]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 0, got %0d", results[0]);
    end

    // Test 2: Check level1[0].level2[1]
    test_count = test_count + 1;
    if (results[1] == 1) begin
      $display("PASS: results[1] = %0d", results[1]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 1, got %0d", results[1]);
    end

    // Test 3: Check level1[1].level2[0]
    test_count = test_count + 1;
    if (results[3] == 10) begin
      $display("PASS: results[3] = %0d", results[3]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 10, got %0d", results[3]);
    end

    // Test 4: Check level1[1].level2[2]
    test_count = test_count + 1;
    if (results[5] == 12) begin
      $display("PASS: results[5] = %0d", results[5]);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 12, got %0d", results[5]);
    end

    // Test 5: Read a localparam of a nested generate block by its name
    test_count = test_count + 1;
    if (level1[1].level2[2].COMPUTED == 12) begin
      $display("PASS: level1[1].level2[2].COMPUTED = %0d", level1[1].level2[2].COMPUTED);
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Expected 12, got %0d", level1[1].level2[2].COMPUTED);
    end

    // Summary
    $display("");
    $display("=== Generate Scope Hierarchy Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All generate scope hierarchy tests passed");
    end else begin
      $display("FAIL: Some generate scope hierarchy tests failed");
    end

    $finish;
  end

endmodule
