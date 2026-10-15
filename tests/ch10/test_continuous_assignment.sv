/*
:name: test_continuous_assignment
:description: Continuous assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_assignment.expected
*/
// IEEE 1800-2023 §10.3 Continuous assignments
// Test continuous assignment behavior

module test_continuous_assignment;
  logic [7:0] a, b;
  logic [7:0] sum;

  // Continuous assignment - updates whenever RHS changes
  assign sum = a + b;

  initial begin
    a = 8'h10;
    b = 8'h20;
    #1;  // Allow continuous assignment to evaluate
    assert(sum == 8'h30) else $fatal(1, "sum should be 0x30, got 0x%0h", sum);

    a = 8'h05;
    #1;
    assert(sum == 8'h25) else $fatal(1, "sum should be 0x25, got 0x%0h", sum);

    b = 8'h15;
    #1;
    assert(sum == 8'h1A) else $fatal(1, "sum should be 0x1A, got 0x%0h", sum);

    $display("PASS: Continuous assignment test completed");
    $finish;
  end
endmodule
