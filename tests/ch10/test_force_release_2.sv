/*
:name: test_force_release_2
:description: Test force/release (IEEE 1800-2023 Section 10.6)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release_2.expected
*/
// Test force/release (IEEE 1800-2023 Section 10.6)

module test_force_release;
  logic [7:0] sig;
  logic clk;
  int pass_count;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    pass_count = 0;
    sig = 8'h00;

    // Test 1: Basic force
    force sig = 8'hAA;
    #1;
    if (sig == 8'hAA) pass_count++;

    // Test 2: Force overrides assignment
    sig = 8'h55;  // Should not work while forced
    #1;
    if (sig == 8'hAA) pass_count++;

    // Test 3: Release
    release sig;
    sig = 8'hBB;
    #1;
    if (sig == 8'hBB) pass_count++;

    // Test 4: Force with expression
    force sig = 8'h11 + 8'h22;
    #1;
    if (sig == 8'h33) pass_count++;
    release sig;

    // Test 5: Multiple force
    force sig = 8'h01;
    #1;
    force sig = 8'h02;
    #1;
    if (sig == 8'h02) pass_count++;
    release sig;

    $display("Force/release tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Force/release tests");
    end else begin
      $display("FAIL: Some force/release tests failed");
    end
    $finish;
  end
endmodule
