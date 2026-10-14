/*
:name: test_if_else_stmt_2
:description: Test: if/else statements with nesting
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 12.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_stmt_2.expected
*/
// Test: if/else statements with nesting

module test_if_else_stmt;
    int pass_count = 0;
    int total_tests = 8;

    // Test variables
    int a, b, c;
    logic [7:0] data;
    bit flag;

    initial begin
        // Test 1: Simple if-true
        a = 5;
        if (a > 0) begin
            pass_count++;
        end

        // Test 2: Simple if-false (no else)
        a = -1;
        if (a > 0) begin
            $display("ERROR: Should not reach here");
        end else begin
            pass_count++;
        end

        // Test 3: if-else chain
        a = 10;
        if (a < 5) begin
            $display("ERROR: a < 5");
        end else if (a < 8) begin
            $display("ERROR: a < 8");
        end else if (a == 10) begin
            pass_count++;
        end else begin
            $display("ERROR: else branch");
        end

        // Test 4: Nested if statements
        a = 3;
        b = 7;
        if (a > 0) begin
            if (b > 5) begin
                if (a + b == 10) begin
                    pass_count++;
                end
            end
        end

        // Test 5: if with compound conditions
        a = 5;
        b = 10;
        c = 15;
        if ((a > 0) && (b > a) && (c > b)) begin
            pass_count++;
        end

        // Test 6: if with bit operations
        data = 8'hA5;
        if (data[7] && !data[6] && data[5]) begin
            pass_count++;
        end

        // Test 7: Empty if body (valid but unusual)
        flag = 1;
        if (!flag) begin
            // empty - should not execute
        end else begin
            pass_count++;
        end

        // Test 8: Deeply nested if-else
        a = 1;
        b = 2;
        c = 3;
        if (a == 1) begin
            if (b == 2) begin
                if (c == 3) begin
                    if (a + b + c == 6) begin
                        pass_count++;
                    end else begin
                        $display("ERROR: Sum check failed");
                    end
                end else begin
                    $display("ERROR: c check failed");
                end
            end else begin
                $display("ERROR: b check failed");
            end
        end else begin
            $display("ERROR: a check failed");
        end

        $display("PASS: if_else_stmt (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
