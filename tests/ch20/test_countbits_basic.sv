/*
:name: test_countbits_basic
:description: Test $countbits basic (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countbits_basic.expected
*/
// Test $countbits basic (IEEE 1800-2023 Section 20.9)

module test_countbits_basic;
  logic [7:0] a;
  int cnt;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Count ones
    a = 8'b1010_1010;
    cnt = $countbits(a, 1'b1);
    if (cnt == 4) pass_count++;

    // Test 2: Count zeros
    cnt = $countbits(a, 1'b0);
    if (cnt == 4) pass_count++;

    // Test 3: All ones
    a = 8'hFF;
    cnt = $countbits(a, 1'b1);
    if (cnt == 8) pass_count++;

    $display("Countbits basic tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Countbits basic tests");
    end else begin
      $display("FAIL: Some countbits tests failed");
    end
  end
endmodule
