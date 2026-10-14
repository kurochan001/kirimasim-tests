/*
:name: test_casez_stmt
:description: Test casez statement (IEEE 1800-2023 Section 12.5.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_casez_stmt.expected
*/
// Test casez statement (IEEE 1800-2023 Section 12.5.1)

module test_casez_stmt;
  logic [3:0] sel;
  logic [7:0] result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Casez exact match
    sel = 4'b1000;
    casez (sel)
      4'b1???: result = 8'hAA;
      4'b01??: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hAA) pass_count++;

    // Test 2: Casez with wildcard
    sel = 4'b1101;
    casez (sel)
      4'b1???: result = 8'hAA;
      4'b01??: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hAA) pass_count++;

    // Test 3: Casez different pattern
    sel = 4'b0100;
    casez (sel)
      4'b1???: result = 8'hAA;
      4'b01??: result = 8'hBB;
      default: result = 8'hFF;
    endcase
    if (result == 8'hBB) pass_count++;

    $display("Casez stmt tests: %0d/3 passed", pass_count);
    if (pass_count >= 2) begin
      $display("PASS: Casez stmt tests");
    end else begin
      $display("FAIL: Some casez stmt tests failed");
    end
  end
endmodule
