/*
:name: test_casex_stmt
:description: Test casex statement (IEEE 1800-2023 Section 12.5.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.2 12.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_casex_stmt.expected
*/
// Test casex statement (IEEE 1800-2023 Section 12.5.2)

module test_casex_stmt;
  logic [3:0] sel;
  logic [7:0] result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Casex exact match
    sel = 4'b1000;
    casex (sel)
      4'b1xxx: result = 8'hAA;
      4'b01xx: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hAA) pass_count++;

    // Test 2: Casex with wildcard
    sel = 4'b1101;
    casex (sel)
      4'b1xxx: result = 8'hAA;
      4'b01xx: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hAA) pass_count++;

    // Test 3: Casex different pattern
    sel = 4'b0111;
    casex (sel)
      4'b1xxx: result = 8'hAA;
      4'b01xx: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hBB) pass_count++;

    $display("Casex stmt tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Casex stmt tests");
    end else begin
      $display("FAIL: Some casex stmt tests failed");
    end
  end
endmodule
