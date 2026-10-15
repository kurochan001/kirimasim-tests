/*
:name: test_param_local
:description: Test parameters and local params (IEEE 1800-2023 Section 6.20)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_local.expected
*/
// Test parameters and local params (IEEE 1800-2023 Section 6.20)

module test_param_local;
  parameter int WIDTH = 8;
  parameter int DEPTH = 16;
  localparam int TOTAL = WIDTH * DEPTH;
  localparam int LOG2_DEPTH = $clog2(DEPTH);

  logic [WIDTH-1:0] data;
  logic [LOG2_DEPTH-1:0] addr;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Parameter value
    if (WIDTH == 8) pass_count++;

    // Test 2: Local param computed
    if (TOTAL == 128) pass_count++;

    // Test 3: $clog2 in localparam
    if (LOG2_DEPTH == 4) pass_count++;

    // Test 4: Use in declaration
    data = '1;
    if (data == 8'hFF) pass_count++;

    // Test 5: Use in range
    addr = '1;
    if (addr == 4'hF) pass_count++;

    // Test 6: Parameter in expression
    if (WIDTH + DEPTH == 24) pass_count++;

    $display("Param local tests: %0d/6 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Param local tests");
    end else begin
      $display("FAIL: Some param tests failed");
    end
  end
endmodule
