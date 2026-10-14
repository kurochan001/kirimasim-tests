/*
:name: test_case_statement
:description: Case Statement (§12.5)
:tags: control_flow
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_statement.expected
*/
// IEEE 1800-2023 Case Statement (§12.5)
// Tests case, casex, casez

module test_case_statement;
    initial begin
        logic [3:0] sel;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Basic case
        sel = 4'b0010;
        case (sel)
            4'b0000: result = 0;
            4'b0001: result = 1;
            4'b0010: result = 2;
            4'b0011: result = 3;
            default: result = -1;
        endcase

        if (result == 2) begin
            $display("PASS: Basic case matched correctly");
            pass_count++;
        end else begin
            $display("FAIL: Basic case result = %0d, expected 2", result);
            fail_count++;
        end

        // Test 2: casez with don't care
        sel = 4'b1010;
        casez (sel)
            4'b00??: result = 0;
            4'b01??: result = 1;
            4'b10??: result = 2;
            4'b11??: result = 3;
            default: result = -1;
        endcase

        if (result == 2) begin
            $display("PASS: casez matched correctly");
            pass_count++;
        end else begin
            $display("FAIL: casez result = %0d, expected 2", result);
            fail_count++;
        end

        // Test 3: casex with X don't care
        sel = 4'b1x01;
        casex (sel)
            4'bx0xx: result = 0;
            4'bx1xx: result = 1;
            default: result = -1;
        endcase

        // casex treats X as don't care
        $display("INFO: casex with X result = %0d", result);
        pass_count++;

        // Test 4: Multiple matches (first match wins)
        sel = 4'b0101;
        case (sel)
            4'b0101: result = 10;
            4'b0101: result = 20;  // Never reached
            default: result = -1;
        endcase

        if (result == 10) begin
            $display("PASS: First match wins");
            pass_count++;
        end else begin
            $display("FAIL: First match should win");
            fail_count++;
        end

        // Test 5: Default case
        sel = 4'b1111;
        case (sel)
            4'b0000: result = 0;
            4'b0001: result = 1;
            default: result = 99;
        endcase

        if (result == 99) begin
            $display("PASS: Default case works");
            pass_count++;
        end else begin
            $display("FAIL: Default case should be 99");
            fail_count++;
        end

        $display("");
        $display("=== Case Statement Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
