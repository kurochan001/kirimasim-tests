/*
:name: test_statement_case
:description: Test case statements (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_statement_case.expected
*/
// Test case statements (IEEE 1800-2023 Section 12.5)

module test_statement_case;
  logic [3:0] sel;
  logic [7:0] result;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Basic case
    sel = 4'd2;
    case (sel)
      4'd0: result = 8'h00;
      4'd1: result = 8'h11;
      4'd2: result = 8'h22;
      4'd3: result = 8'h33;
      default: result = 8'hFF;
    endcase
    if (result == 8'h22) pass_count++;

    // Test 2: Default case
    sel = 4'd10;
    case (sel)
      4'd0: result = 8'h00;
      4'd1: result = 8'h11;
      default: result = 8'hDD;
    endcase
    if (result == 8'hDD) pass_count++;

    // Test 3: casez with wildcards
    sel = 4'b1?00;
    casez (sel)
      4'b0???: result = 8'h01;
      4'b10??: result = 8'h02;
      4'b11??: result = 8'h03;
      default: result = 8'h00;
    endcase
    if (result == 8'h02) pass_count++;  // z in the case expression is a don't-care bit

    // Test 4: casex with don't cares
    sel = 4'b1x01;
    casex (sel)
      4'bxxx0: result = 8'h10;
      4'bxxx1: result = 8'h11;
      default: result = 8'h00;
    endcase
    if (result == 8'h11) pass_count++;

    // Test 5: Multiple items per case
    sel = 4'd5;
    case (sel)
      4'd0, 4'd1, 4'd2: result = 8'hAA;
      4'd3, 4'd4, 4'd5: result = 8'hBB;
      default: result = 8'hCC;
    endcase
    if (result == 8'hBB) pass_count++;

    // Test 6: Nested case
    sel = 4'd1;
    case (sel)
      4'd0: result = 8'h00;
      4'd1: begin
        case (result)
          8'hBB: result = 8'h01;
          default: result = 8'h02;
        endcase
      end
      default: result = 8'hFF;
    endcase
    if (result == 8'h01) pass_count++;

    $display("Case statement tests: %0d/6 passed", pass_count);
    if (pass_count == 6) begin
      $display("PASS: Case statement tests");
    end else begin
      $display("FAIL: Some case statement tests failed");
    end
  end
endmodule
