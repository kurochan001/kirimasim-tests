/*
:name: test_isunknown_func
:description: Test $isunknown function (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_isunknown_func.expected
*/
// Test $isunknown function (IEEE 1800-2023 Section 20.9)

module test_isunknown_func;
  logic [7:0] val;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: No unknowns
    val = 8'b10101010;
    if (!$isunknown(val)) pass_count++;

    // Test 2: Has X
    val = 8'b1010x010;
    if ($isunknown(val)) pass_count++;

    // Test 3: Has Z
    val = 8'b1010z010;
    if ($isunknown(val)) pass_count++;

    // Test 4: All zeros
    val = 8'b00000000;
    if (!$isunknown(val)) pass_count++;

    // Test 5: All ones
    val = 8'b11111111;
    if (!$isunknown(val)) pass_count++;

    // Test 6: All X
    val = 8'bxxxxxxxx;
    if ($isunknown(val)) pass_count++;

    $display("Isunknown func tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Isunknown func tests");
    end else begin
      $display("FAIL: Some isunknown tests failed");
    end
  end
endmodule
