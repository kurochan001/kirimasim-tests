/*
:name: test_label_stmt
:description: Test statement labels (IEEE 1800-2023 Section 12.7)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 9.3.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_label_stmt.expected
*/
// Test statement labels (IEEE 1800-2023 Section 12.7)

module test_label_stmt;
  int i, count;
  int pass_count;

  initial begin
    pass_count = 0;
    count = 0;

    // Test 1: Basic label
    label1: count = 1;
    if (count == 1) pass_count++;

    // Test 2: Label with block
    label2: begin
      count = 2;
    end
    if (count == 2) pass_count++;

    // Test 3: Loop with label
    loop_label: for (i = 0; i < 3; i++) begin
      count++;
    end
    if (count == 5) pass_count++;

    // Test 4: Nested labels
    outer: begin
      inner: begin
        count = 10;
      end
    end
    if (count == 10) pass_count++;

    // Test 5: If with label
    cond_label: if (count > 5) begin
      count = 20;
    end
    if (count == 20) pass_count++;

    $display("Label stmt tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Label stmt tests");
    end else begin
      $display("FAIL: Some label tests failed");
    end
  end
endmodule
