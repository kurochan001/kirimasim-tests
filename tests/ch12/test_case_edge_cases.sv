/*
:name: test_case_edge_cases
:description: Case statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_edge_cases.expected
*/
// IEEE 1800-2023 §12.5: Case statement edge cases
// Tests for case, casex, casez

module test_case_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] sel;
    int result;

    initial begin
        // Test 1: Case match first
        test_count++;
        sel = 4'b0001;
        case (sel)
            4'b0001: result = 1;
            4'b0010: result = 2;
            default: result = 0;
        endcase
        if (result == 1) begin
            pass_count++;
            $display("Test 1 PASS: Case match = %0d", result);
        end else begin
            $display("Test 1 FAIL: Case unexpected = %0d", result);
        end

        // Test 2: Case match second
        test_count++;
        sel = 4'b0010;
        case (sel)
            4'b0001: result = 1;
            4'b0010: result = 2;
            default: result = 0;
        endcase
        if (result == 2) begin
            pass_count++;
            $display("Test 2 PASS: Second match = %0d", result);
        end else begin
            $display("Test 2 FAIL: Second unexpected = %0d", result);
        end

        // Test 3: Case default
        test_count++;
        sel = 4'b1111;
        case (sel)
            4'b0001: result = 1;
            4'b0010: result = 2;
            default: result = 99;
        endcase
        if (result == 99) begin
            pass_count++;
            $display("Test 3 PASS: Default = %0d", result);
        end else begin
            $display("Test 3 FAIL: Default unexpected = %0d", result);
        end

        // Test 4: Casez with ?
        test_count++;
        sel = 4'b1001;
        casez (sel)
            4'b1??1: result = 10;
            4'b0??0: result = 20;
            default: result = 0;
        endcase
        if (result == 10) begin
            pass_count++;
            $display("Test 4 PASS: Casez = %0d", result);
        end else begin
            $display("Test 4 FAIL: Casez unexpected = %0d", result);
        end

        // Test 5: Casex with x
        test_count++;
        sel = 4'b1010;
        casex (sel)
            4'b1x1x: result = 30;
            4'b0x0x: result = 40;
            default: result = 0;
        endcase
        if (result == 30) begin
            pass_count++;
            $display("Test 5 PASS: Casex = %0d", result);
        end else begin
            $display("Test 5 FAIL: Casex unexpected = %0d", result);
        end

        // Test 6: Multiple items
        test_count++;
        sel = 4'b0100;
        case (sel)
            4'b0001, 4'b0010, 4'b0100: result = 50;
            default: result = 0;
        endcase
        if (result == 50) begin
            pass_count++;
            $display("Test 6 PASS: Multi item = %0d", result);
        end else begin
            $display("Test 6 FAIL: Multi unexpected = %0d", result);
        end

        // Test 7: Case with expression
        test_count++;
        sel = 4'b0011;
        case (sel + 4'b0001)
            4'b0100: result = 60;
            default: result = 0;
        endcase
        if (result == 60) begin
            pass_count++;
            $display("Test 7 PASS: Expr case = %0d", result);
        end else begin
            $display("Test 7 FAIL: Expr unexpected = %0d", result);
        end

        // Test 8: Nested case (simplified)
        test_count++;
        sel = 4'b0001;
        case (sel)
            4'b0001: begin
                case (1'b1)
                    1'b1: result = 70;
                    default: result = 0;
                endcase
            end
            default: result = 0;
        endcase
        if (result == 70) begin
            pass_count++;
            $display("Test 8 PASS: Nested = %0d", result);
        end else begin
            $display("Test 8 FAIL: Nested unexpected = %0d", result);
        end

        // Test 9: All zeros
        test_count++;
        sel = 4'b0000;
        case (sel)
            4'b0000: result = 80;
            default: result = 0;
        endcase
        if (result == 80) begin
            pass_count++;
            $display("Test 9 PASS: Zero sel = %0d", result);
        end else begin
            $display("Test 9 FAIL: Zero unexpected = %0d", result);
        end

        // Test 10: All ones
        test_count++;
        sel = 4'b1111;
        case (sel)
            4'b1111: result = 90;
            default: result = 0;
        endcase
        if (result == 90) begin
            pass_count++;
            $display("Test 10 PASS: All ones = %0d", result);
        end else begin
            $display("Test 10 FAIL: Ones unexpected = %0d", result);
        end

        $display("=== Case Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
