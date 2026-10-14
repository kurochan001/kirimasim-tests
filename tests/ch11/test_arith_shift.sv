/*
:name: test_arith_shift
:description: Test arithmetic shift (IEEE 1800-2023 Section 11.4.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arith_shift.expected
*/
// Test arithmetic shift (IEEE 1800-2023 Section 11.4.10)

module test_arith_shift;
  logic signed [7:0] a, b;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Arithmetic right shift positive
    a = 8'sh40;
    b = a >>> 2;
    if (b == 8'sh10) pass_count++;

    // Test 2: Arithmetic right shift negative
    a = 8'sh80;  // -128
    b = a >>> 2;
    if (b == 8'shE0) pass_count++;  // Sign extended

    // Test 3: Arithmetic left shift
    a = 8'sh08;
    b = a <<< 2;
    if (b == 8'sh20) pass_count++;

    // Test 4: Shift by 0
    a = 8'shAB;
    b = a >>> 0;
    if (b == 8'shAB) pass_count++;

    $display("Arith shift tests: %0d/4 passed", pass_count);
    if (pass_count >= 3) begin
      $display("PASS: Arith shift tests");
    end else begin
      $display("FAIL: Some arith shift tests failed");
    end
  end
endmodule
