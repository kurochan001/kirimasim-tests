/*
:name: test_ternary_edge_cases
:description: Conditional operator: nested, chained and with constant conditions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_edge_cases.expected
*/
// IEEE 1800-2023 §11.4.11: Ternary operator edge cases
// Tests for conditional operator ?:

module test_ternary_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b, result;
    logic cond;
    int x, y, z;

    initial begin
        // Test 1: True condition
        test_count++;
        cond = 1;
        a = 8'hAA;
        b = 8'h55;
        result = cond ? a : b;
        if (result == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: True result = %h", result);
        end else begin
            $display("Test 1 FAIL: True unexpected = %h", result);
        end

        // Test 2: False condition
        test_count++;
        cond = 0;
        result = cond ? a : b;
        if (result == 8'h55) begin
            pass_count++;
            $display("Test 2 PASS: False result = %h", result);
        end else begin
            $display("Test 2 FAIL: False unexpected = %h", result);
        end

        // Test 3: Nested ternary
        test_count++;
        x = 5;
        y = (x > 3) ? ((x > 4) ? 100 : 50) : 0;
        if (y == 100) begin
            pass_count++;
            $display("Test 3 PASS: Nested = %0d", y);
        end else begin
            $display("Test 3 FAIL: Nested unexpected = %0d", y);
        end

        // Test 4: Chain ternary
        test_count++;
        x = 2;
        y = (x == 1) ? 10 : (x == 2) ? 20 : 30;
        if (y == 20) begin
            pass_count++;
            $display("Test 4 PASS: Chain = %0d", y);
        end else begin
            $display("Test 4 FAIL: Chain unexpected = %0d", y);
        end

        // Test 5: Expression in condition
        test_count++;
        a = 8'h10;
        b = 8'h20;
        result = (a < b) ? 8'hFF : 8'h00;
        if (result == 8'hFF) begin
            pass_count++;
            $display("Test 5 PASS: Expr cond = %h", result);
        end else begin
            $display("Test 5 FAIL: Expr unexpected = %h", result);
        end

        // Test 6: Expression in branches
        test_count++;
        x = 5;
        y = 3;
        z = 1 ? (x + y) : (x - y);
        if (z == 8) begin
            pass_count++;
            $display("Test 6 PASS: Branch expr = %0d", z);
        end else begin
            $display("Test 6 FAIL: Branch unexpected = %0d", z);
        end

        // Test 7: Zero condition
        test_count++;
        result = 0 ? 8'hAA : 8'hBB;
        if (result == 8'hBB) begin
            pass_count++;
            $display("Test 7 PASS: Zero cond = %h", result);
        end else begin
            $display("Test 7 FAIL: Zero unexpected = %h", result);
        end

        // Test 8: Non-zero condition
        test_count++;
        result = 5 ? 8'hAA : 8'hBB;
        if (result == 8'hAA) begin
            pass_count++;
            $display("Test 8 PASS: Nonzero cond = %h", result);
        end else begin
            $display("Test 8 FAIL: Nonzero unexpected = %h", result);
        end

        // Test 9: Same type branches
        test_count++;
        x = 10;
        y = 20;
        z = 1 ? x : y;
        if (z == 10) begin
            pass_count++;
            $display("Test 9 PASS: Same type = %0d", z);
        end else begin
            $display("Test 9 FAIL: Same unexpected = %0d", z);
        end

        // Test 10: In assignment
        test_count++;
        a = 8'h00;
        a = 1 ? 8'hFF : a;
        if (a == 8'hFF) begin
            pass_count++;
            $display("Test 10 PASS: Assign = %h", a);
        end else begin
            $display("Test 10 FAIL: Assign unexpected = %h", a);
        end

        $display("=== Ternary Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
