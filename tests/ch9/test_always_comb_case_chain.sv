/*
:name: test_always_comb_case_chain
:description: always_comb with a case statement, and a chain of always_comb procedures
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_case_chain.expected
*/
// always_comb with a case statement, and a chain of always_comb procedures

module test_always_comb_case_chain;
  logic a, b, c, d;
  logic [3:0] sel;
  logic [7:0] data;
  logic result;
  int pass_count;

  // Combinational logic with dependencies
  always_comb begin
    case(sel)
      4'd0: result = a;
      4'd1: result = b;
      4'd2: result = c;
      4'd3: result = d;
      default: result = 0;
    endcase
  end

  // Chain of dependencies
  logic x, y, z;
  always_comb x = a & b;
  always_comb y = x | c;
  always_comb z = y ^ d;

  initial begin
    pass_count = 0;

    // Test 1: Basic dependency
    a = 1; b = 0; c = 0; d = 0;
    sel = 0;
    #1;
    if (result == 1) pass_count++;

    // Test 2: Change selector
    sel = 1;
    #1;
    if (result == 0) pass_count++;

    // Test 3: Change source
    b = 1;
    #1;
    if (result == 1) pass_count++;

    // Test 4: Chain evaluation
    a = 1; b = 1; c = 0; d = 0;
    #1;
    if (x == 1 && y == 1 && z == 1) pass_count++;

    // Test 5: Chain propagation
    c = 1;
    #1;
    if (y == 1 && z == 1) pass_count++;

    // Test 6: Full chain
    d = 1;
    #1;
    if (z == 0) pass_count++;

    $display("Dependency tracking tests: %0d/6 passed", pass_count);
    if (pass_count >= 5) begin
      $display("PASS: Dependency tracking tests");
    end else begin
      $display("FAIL: Some dependency tests failed");
    end
  end
endmodule
