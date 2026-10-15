/*
:name: test_divider_edge_cases
:description: Divider edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 9.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_divider_edge_cases.expected
*/
// IEEE 1800-2023: Divider edge cases
// Tests for division constructs

module test_divider_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] dividend, divisor;
    logic [7:0] quotient, remainder;
    logic div_by_zero;

    // Simple divider
    always_comb begin
        if (divisor == 0) begin
            quotient = 8'hFF;
            remainder = 8'hFF;
            div_by_zero = 1;
        end else begin
            quotient = dividend / divisor;
            remainder = dividend % divisor;
            div_by_zero = 0;
        end
    end

    initial begin
        // Test 1: Simple division
        test_count++;
        dividend = 100; divisor = 10;
        #1;
        if (quotient == 10 && remainder == 0) begin
            pass_count++;
            $display("Test 1 PASS: 100/10=%0d r%0d", quotient, remainder);
        end else begin
            $display("Test 1 FAIL: unexpected q=%0d r=%0d", quotient, remainder);
        end

        // Test 2: Division with remainder
        test_count++;
        dividend = 17; divisor = 5;
        #1;
        if (quotient == 3 && remainder == 2) begin
            pass_count++;
            $display("Test 2 PASS: 17/5=%0d r%0d", quotient, remainder);
        end else begin
            $display("Test 2 FAIL: unexpected q=%0d r=%0d", quotient, remainder);
        end

        // Test 3: Division by 1
        test_count++;
        dividend = 8'hAB; divisor = 1;
        #1;
        if (quotient == 8'hAB && remainder == 0) begin
            pass_count++;
            $display("Test 3 PASS: AB/1=%h r%0d", quotient, remainder);
        end else begin
            $display("Test 3 FAIL: unexpected");
        end

        // Test 4: Zero dividend
        test_count++;
        dividend = 0; divisor = 10;
        #1;
        if (quotient == 0 && remainder == 0) begin
            pass_count++;
            $display("Test 4 PASS: 0/10=%0d r%0d", quotient, remainder);
        end else begin
            $display("Test 4 FAIL: unexpected");
        end

        // Test 5: Division by zero
        test_count++;
        dividend = 100; divisor = 0;
        #1;
        if (div_by_zero == 1) begin
            pass_count++;
            $display("Test 5 PASS: div_by_zero=%b", div_by_zero);
        end else begin
            $display("Test 5 FAIL: unexpected div_by_zero=%b", div_by_zero);
        end

        // Test 6: Dividend less than divisor
        test_count++;
        dividend = 5; divisor = 10;
        #1;
        if (quotient == 0 && remainder == 5) begin
            pass_count++;
            $display("Test 6 PASS: 5/10=%0d r%0d", quotient, remainder);
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: Max value division
        test_count++;
        dividend = 8'hFF; divisor = 8'hFF;
        #1;
        if (quotient == 1 && remainder == 0) begin
            pass_count++;
            $display("Test 7 PASS: FF/FF=%0d r%0d", quotient, remainder);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        $display("=== Divider Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
