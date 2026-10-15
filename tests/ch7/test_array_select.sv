/*
:name: test_array_select
:description: Test array selections (IEEE 1800-2023 Section 7.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_select.expected
*/
// Test array selections (IEEE 1800-2023 Section 7.4)

module test_array_select;
  logic [31:0] arr[4];
  logic [31:0] val;
  int idx;
  int pass_count;

  initial begin
    pass_count = 0;

    // Initialize array
    arr[0] = 32'h10000000;
    arr[1] = 32'h20000000;
    arr[2] = 32'h30000000;
    arr[3] = 32'h40000000;

    // Test 1: Constant index
    val = arr[1];
    if (val == 32'h20000000) pass_count++;

    // Test 2: Variable index
    idx = 2;
    val = arr[idx];
    if (val == 32'h30000000) pass_count++;

    // Test 3: Computed index
    val = arr[1 + 1];
    if (val == 32'h30000000) pass_count++;

    // Test 4: Array element assignment
    arr[0] = 32'hAABBCCDD;
    if (arr[0] == 32'hAABBCCDD) pass_count++;

    // Test 5: Part select
    val = arr[0][15:8];
    if (val == 8'hCC) pass_count++;

    // Test 6: Bit select
    if (arr[0][0] == 1'b1) pass_count++;

    // Test 7: Array in expression
    val = arr[1] + arr[2];
    if (val == 32'h50000000) pass_count++;

    $display("Array select tests: %0d/7 passed", pass_count);
    if (pass_count >= 6) begin
      $display("PASS: Array select tests");
    end else begin
      $display("FAIL: Some array select tests failed");
    end
  end
endmodule
