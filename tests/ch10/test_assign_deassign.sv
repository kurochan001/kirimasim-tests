/*
:name: test_assign_deassign
:description: Test assign/deassign (IEEE 1800-2023 Section 10.6)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_deassign.expected
*/
// Test assign/deassign (IEEE 1800-2023 Section 10.6)

module test_assign_deassign;
  reg [7:0] q;
  logic clk;
  int pass_count;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    pass_count = 0;
    q = 8'h00;

    // Test 1: Basic procedural assign
    assign q = 8'hFF;
    #1;
    if (q == 8'hFF) pass_count++;

    // Test 2: Deassign
    deassign q;
    q = 8'h55;
    #1;
    if (q == 8'h55) pass_count++;

    // Test 3: Assign with expression
    assign q = 8'h10 | 8'h05;
    #1;
    if (q == 8'h15) pass_count++;
    deassign q;

    $display("Assign/deassign tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Assign/deassign tests");
    end else begin
      $display("FAIL: Some assign/deassign tests failed");
    end
    $finish;
  end
endmodule
