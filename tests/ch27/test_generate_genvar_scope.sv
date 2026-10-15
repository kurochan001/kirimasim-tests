/*
:name: test_generate_genvar_scope
:description: Test for genvar scope management (IEEE 1800-2023 §27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_genvar_scope.expected
*/
// Test for genvar scope management (IEEE 1800-2023 §27.4)
// Tests genvar visibility and inheritance in nested scopes

module test_generate_genvar_scope;

  parameter int SIZE = 4;
  int outer_results[SIZE];
  int inner_results[SIZE][2];
  int pass_count = 0;
  int test_count = 0;

  // Outer genvar
  generate
    genvar outer_i;
    for (outer_i = 0; outer_i < SIZE; outer_i = outer_i + 1) begin : outer_loop
      // Only stores the value: the order of these initial blocks at time 0
      // is not defined, so the values are printed later from one block.
      initial outer_results[outer_i] = outer_i * 10;

      // Inner genvar (different name)
      genvar inner_j;
      for (inner_j = 0; inner_j < 2; inner_j = inner_j + 1) begin : inner_loop
        initial inner_results[outer_i][inner_j] = outer_i * 10 + inner_j;
      end
    end
  endgenerate

  initial begin
    #1;  // Wait for generate initial blocks
    for (int k = 0; k < SIZE; k++) begin
      $display("Outer[%0d] = %0d", k, outer_results[k]);
      for (int m = 0; m < 2; m++)
        $display("Inner[%0d][%0d] = %0d", k, m, inner_results[k][m]);
    end

    // Test 1: Outer genvar values
    test_count = test_count + 1;
    if (outer_results[0] == 0 &&
        outer_results[1] == 10 &&
        outer_results[2] == 20 &&
        outer_results[3] == 30) begin
      $display("PASS: Outer genvar values correct");
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Outer genvar values incorrect: %0d,%0d,%0d,%0d",
               outer_results[0], outer_results[1], outer_results[2], outer_results[3]);
    end

    // Test 2: Inner genvar with outer genvar access
    test_count = test_count + 1;
    if (inner_results[0][0] == 0 &&
        inner_results[0][1] == 1 &&
        inner_results[1][0] == 10 &&
        inner_results[1][1] == 11) begin
      $display("PASS: Inner genvar with outer access correct");
      pass_count = pass_count + 1;
    end else begin
      $display("FAIL: Inner genvar values incorrect");
    end

    // Test 3: Verify all outer values
    test_count = test_count + 1;
    begin
      static bit all_correct = 1;
      for (int k = 0; k < SIZE; k = k + 1) begin
        if (outer_results[k] != k * 10) begin
          all_correct = 0;
        end
      end
      if (all_correct) begin
        $display("PASS: All outer loop values verified");
        pass_count = pass_count + 1;
      end else begin
        $display("FAIL: Some outer loop values incorrect");
      end
    end

    // Test 4: Verify all inner values
    test_count = test_count + 1;
    begin
      static bit all_correct = 1;
      for (int k = 0; k < SIZE; k = k + 1) begin
        for (int m = 0; m < 2; m = m + 1) begin
          if (inner_results[k][m] != k * 10 + m) begin
            all_correct = 0;
          end
        end
      end
      if (all_correct) begin
        $display("PASS: All inner loop values verified");
        pass_count = pass_count + 1;
      end else begin
        $display("FAIL: Some inner loop values incorrect");
      end
    end

    // Summary
    $display("");
    $display("=== Genvar Scope Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All genvar scope tests passed");
    end else begin
      $display("FAIL: Some genvar scope tests failed");
    end

    $finish;
  end

endmodule
