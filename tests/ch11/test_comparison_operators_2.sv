/*
:name: test_comparison_operators_2
:description: Relational, equality, case equality and wildcard equality operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comparison_operators_2.expected
*/
// IEEE 1800-2023 §11.4.4-5 Relational and Equality Operators
// Tests <, <=, >, >=, ==, !=, ===, !==, ==?, !=?

module test_comparison_operators;
    logic [7:0] a, b;
    logic [3:0] x, y;
    logic result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Relational operators
        a = 8'd10; b = 8'd20;
        
        // Test 1: Less than
        if ((a < b) == 1'b1) begin
            $display("PASS: 10 < 20");
            pass_count++;
        end else begin
            $display("FAIL: 10 < 20");
            fail_count++;
        end

        // Test 2: Less than or equal
        if ((a <= b) == 1'b1) begin
            $display("PASS: 10 <= 20");
            pass_count++;
        end else begin
            $display("FAIL: 10 <= 20");
            fail_count++;
        end

        // Test 3: Greater than
        if ((b > a) == 1'b1) begin
            $display("PASS: 20 > 10");
            pass_count++;
        end else begin
            $display("FAIL: 20 > 10");
            fail_count++;
        end

        // Test 4: Greater than or equal
        a = 8'd20;
        if ((a >= b) == 1'b1) begin
            $display("PASS: 20 >= 20");
            pass_count++;
        end else begin
            $display("FAIL: 20 >= 20");
            fail_count++;
        end

        // Equality operators
        a = 8'd100; b = 8'd100;
        
        // Test 5: Logical equality
        if ((a == b) == 1'b1) begin
            $display("PASS: 100 == 100");
            pass_count++;
        end else begin
            $display("FAIL: 100 == 100");
            fail_count++;
        end

        // Test 6: Logical inequality
        b = 8'd50;
        if ((a != b) == 1'b1) begin
            $display("PASS: 100 != 50");
            pass_count++;
        end else begin
            $display("FAIL: 100 != 50");
            fail_count++;
        end

        // Test 7: Case equality (===) with X
        x = 4'b10x1;
        y = 4'b10x1;
        if (x === y) begin
            $display("PASS: 4'b10x1 === 4'b10x1");
            pass_count++;
        end else begin
            $display("FAIL: 4'b10x1 === 4'b10x1");
            fail_count++;
        end

        // Test 8: Case inequality (!==) with X
        y = 4'b10x0;
        if (x !== y) begin
            $display("PASS: 4'b10x1 !== 4'b10x0");
            pass_count++;
        end else begin
            $display("FAIL: 4'b10x1 !== 4'b10x0");
            fail_count++;
        end

        // Test 9: Wildcard equality (==?) - X/Z in pattern match any
        x = 4'b1010;
        y = 4'b10x0;  // X matches 1
        if (x ==? y) begin
            $display("PASS: 4'b1010 ==? 4'b10x0 (wildcard match)");
            pass_count++;
        end else begin
            $display("FAIL: 4'b1010 ==? 4'b10x0");
            fail_count++;
        end

        // Test 10: Wildcard inequality (!=?)
        x = 4'b1011;
        y = 4'b10x0;  // X matches anything, but last bit differs
        if (x !=? y) begin
            $display("PASS: 4'b1011 !=? 4'b10x0");
            pass_count++;
        end else begin
            $display("FAIL: 4'b1011 !=? 4'b10x0");
            fail_count++;
        end

        $display("");
        $display("=== Comparison Operators Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
