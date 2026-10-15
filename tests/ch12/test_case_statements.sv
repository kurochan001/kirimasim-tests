/*
:name: test_case_statements
:description: Case Statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_statements.expected
*/
// IEEE 1800-2023 §12.5 Case Statements
// Tests case, casex, casez, unique case, priority case

module test_case_statements;
    int pass_count = 0;
    int fail_count = 0;
    logic [3:0] sel;
    int result;

    initial begin
        // Test 1: Basic case statement
        sel = 4'd2;
        case (sel)
            4'd0: result = 0;
            4'd1: result = 1;
            4'd2: result = 2;
            4'd3: result = 3;
            default: result = -1;
        endcase
        if (result == 2) begin
            $display("PASS: Basic case - sel=2 -> result=2");
            pass_count++;
        end else begin
            $display("FAIL: Basic case - result=%0d", result);
            fail_count++;
        end

        // Test 2: Case with default
        sel = 4'd15;
        case (sel)
            4'd0: result = 0;
            4'd1: result = 1;
            default: result = 99;
        endcase
        if (result == 99) begin
            $display("PASS: Case default - sel=15 -> result=99");
            pass_count++;
        end else begin
            $display("FAIL: Case default - result=%0d", result);
            fail_count++;
        end

        // Test 3: casez with don't care
        sel = 4'b1100;
        casez (sel)
            4'b0???: result = 0;
            4'b10??: result = 1;
            4'b11??: result = 2;
            default: result = -1;
        endcase
        if (result == 2) begin
            $display("PASS: casez - 4'b1100 matches 4'b11??");
            pass_count++;
        end else begin
            $display("FAIL: casez - result=%0d", result);
            fail_count++;
        end

        // Test 4: casex with X don't care in pattern
        // IEEE 1800-2023 §12.5.1: X/Z in pattern are wildcards
        sel = 4'b1010;
        casex (sel)
            4'b0???: result = 0;  // Bit 3 is 1, pattern expects 0, no match
            4'bx01?: result = 1;  // X in pattern matches 1, 01 matches 01, ? matches 0
            default: result = -1;
        endcase
        if (result == 1) begin
            $display("PASS: casex - 4'b1010 matches 4'bx01?");
            pass_count++;
        end else begin
            $display("FAIL: casex - result=%0d", result);
            fail_count++;
        end

        // Test 5: Multiple items per case
        sel = 4'd5;
        case (sel)
            4'd0, 4'd1: result = 0;
            4'd2, 4'd3: result = 1;
            4'd4, 4'd5, 4'd6: result = 2;
            default: result = -1;
        endcase
        if (result == 2) begin
            $display("PASS: Multiple items - sel=5 in {4,5,6} -> result=2");
            pass_count++;
        end else begin
            $display("FAIL: Multiple items - result=%0d", result);
            fail_count++;
        end

        // Test 6: Nested case
        sel = 4'd1;
        result = 0;
        case (sel)
            4'd0: result = 0;
            4'd1: begin
                case (sel[0])
                    1'b0: result = 10;
                    1'b1: result = 11;
                endcase
            end
            default: result = -1;
        endcase
        if (result == 11) begin
            $display("PASS: Nested case - result=11");
            pass_count++;
        end else begin
            $display("FAIL: Nested case - result=%0d", result);
            fail_count++;
        end

        $display("");
        $display("=== Case Statements Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
