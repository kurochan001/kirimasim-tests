/*
:name: test_const_expr
:description: Test constant expressions (IEEE 1800-2023 Section 11.2.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.20.2 20.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_const_expr.expected
*/
// Test constant expressions (IEEE 1800-2023 Section 11.2.1)

module test_const_expr;
  localparam int A = 10;
  localparam int B = A * 2;
  localparam int C = B + 5;
  localparam int D = (A > B) ? A : B;
  localparam int ARR_SIZE = C / 5;

  logic [ARR_SIZE-1:0] arr;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Simple constant
    if (A == 10) pass_count++;

    // Test 2: Computed constant
    if (B == 20) pass_count++;

    // Test 3: Chained constant
    if (C == 25) pass_count++;

    // Test 4: Conditional constant
    if (D == 20) pass_count++;

    // Test 5: Array size constant
    if (ARR_SIZE == 5) pass_count++;

    // Test 6: Array with const size
    arr = '1;
    if ($bits(arr) == 5) pass_count++;

    $display("Const expr tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Const expr tests");
    end else begin
      $display("FAIL: Some const tests failed");
    end
  end
endmodule
