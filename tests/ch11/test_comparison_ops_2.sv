/*
:name: test_comparison_ops_2
:description: Equality and relational operators on int, vector, real and string values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparison_ops_2.expected
*/
// Equality and relational operators on int, vector, real and string values

module test_comparison_ops;
    int pass_count = 0;
    int total_tests = 30;

    // Test variables
    int a, b;
    logic [7:0] va, vb;
    real ra, rb;
    string sa, sb;
    logic result;

    initial begin
        // Test 1: Equal - true case
        a = 42; b = 42;
        result = (a == b);
        if (result == 1'b1) begin
            $display("Test 1 PASSED: 42 == 42 is true");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Equal - false case
        a = 42; b = 43;
        result = (a == b);
        if (result == 1'b0) begin
            $display("Test 2 PASSED: 42 == 43 is false");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Not equal - true case
        a = 10; b = 20;
        result = (a != b);
        if (result == 1'b1) begin
            $display("Test 3 PASSED: 10 != 20 is true");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Not equal - false case
        a = 50; b = 50;
        result = (a != b);
        if (result == 1'b0) begin
            $display("Test 4 PASSED: 50 != 50 is false");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Less than - true case
        a = 5; b = 10;
        result = (a < b);
        if (result == 1'b1) begin
            $display("Test 5 PASSED: 5 < 10 is true");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Less than - false case
        a = 10; b = 5;
        result = (a < b);
        if (result == 1'b0) begin
            $display("Test 6 PASSED: 10 < 5 is false");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Less than - equal case
        a = 7; b = 7;
        result = (a < b);
        if (result == 1'b0) begin
            $display("Test 7 PASSED: 7 < 7 is false");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Greater than - true case
        a = 100; b = 50;
        result = (a > b);
        if (result == 1'b1) begin
            $display("Test 8 PASSED: 100 > 50 is true");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Greater than - false case
        a = 25; b = 75;
        result = (a > b);
        if (result == 1'b0) begin
            $display("Test 9 PASSED: 25 > 75 is false");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Greater than - equal case
        a = 33; b = 33;
        result = (a > b);
        if (result == 1'b0) begin
            $display("Test 10 PASSED: 33 > 33 is false");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Less than or equal - less case
        a = 3; b = 5;
        result = (a <= b);
        if (result == 1'b1) begin
            $display("Test 11 PASSED: 3 <= 5 is true");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Less than or equal - equal case
        a = 8; b = 8;
        result = (a <= b);
        if (result == 1'b1) begin
            $display("Test 12 PASSED: 8 <= 8 is true");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: Less than or equal - greater case
        a = 15; b = 10;
        result = (a <= b);
        if (result == 1'b0) begin
            $display("Test 13 PASSED: 15 <= 10 is false");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Greater than or equal - greater case
        a = 90; b = 80;
        result = (a >= b);
        if (result == 1'b1) begin
            $display("Test 14 PASSED: 90 >= 80 is true");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Greater than or equal - equal case
        a = 55; b = 55;
        result = (a >= b);
        if (result == 1'b1) begin
            $display("Test 15 PASSED: 55 >= 55 is true");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Greater than or equal - less case
        a = 20; b = 40;
        result = (a >= b);
        if (result == 1'b0) begin
            $display("Test 16 PASSED: 20 >= 40 is false");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Negative number comparison
        a = -10; b = -5;
        result = (a < b);
        if (result == 1'b1) begin
            $display("Test 17 PASSED: -10 < -5 is true");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Negative vs positive
        a = -1; b = 1;
        result = (a < b);
        if (result == 1'b1) begin
            $display("Test 18 PASSED: -1 < 1 is true");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Zero comparison
        a = 0; b = 0;
        result = (a == b);
        if (result == 1'b1) begin
            $display("Test 19 PASSED: 0 == 0 is true");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Logic vector comparison
        va = 8'hAA; vb = 8'hAA;
        result = (va == vb);
        if (result == 1'b1) begin
            $display("Test 20 PASSED: 0xAA == 0xAA is true");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Logic vector less than
        va = 8'h10; vb = 8'h20;
        result = (va < vb);
        if (result == 1'b1) begin
            $display("Test 21 PASSED: 0x10 < 0x20 is true");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Real number equal
        ra = 3.14; rb = 3.14;
        result = (ra == rb);
        if (result == 1'b1) begin
            $display("Test 22 PASSED: 3.14 == 3.14 is true");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Real number less than
        ra = 2.5; rb = 3.5;
        result = (ra < rb);
        if (result == 1'b1) begin
            $display("Test 23 PASSED: 2.5 < 3.5 is true");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Real number greater than
        ra = 10.0; rb = 5.0;
        result = (ra > rb);
        if (result == 1'b1) begin
            $display("Test 24 PASSED: 10.0 > 5.0 is true");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: String equal
        sa = "hello"; sb = "hello";
        result = (sa == sb);
        if (result == 1'b1) begin
            $display("Test 25 PASSED: \"hello\" == \"hello\" is true");
            pass_count++;
        end else $display("Test 25 FAILED");

        // Test 26: String not equal
        sa = "abc"; sb = "xyz";
        result = (sa != sb);
        if (result == 1'b1) begin
            $display("Test 26 PASSED: \"abc\" != \"xyz\" is true");
            pass_count++;
        end else $display("Test 26 FAILED");

        // Test 27: Chained comparison (a < b < c style not directly supported, use &&)
        a = 5; b = 10;
        result = (a < b) && (b < 15);
        if (result == 1'b1) begin
            $display("Test 27 PASSED: 5 < 10 && 10 < 15 is true");
            pass_count++;
        end else $display("Test 27 FAILED");

        // Test 28: Boundary - max int
        a = 2147483647; b = 2147483647;
        result = (a == b);
        if (result == 1'b1) begin
            $display("Test 28 PASSED: MAX_INT == MAX_INT is true");
            pass_count++;
        end else $display("Test 28 FAILED");

        // Test 29: Comparison with expression
        a = 10; b = 5;
        result = ((a + b) == 15);
        if (result == 1'b1) begin
            $display("Test 29 PASSED: (10 + 5) == 15 is true");
            pass_count++;
        end else $display("Test 29 FAILED");

        // Test 30: Complex comparison
        a = 100; b = 50;
        result = ((a > b) && (a != 0) && (b >= 50));
        if (result == 1'b1) begin
            $display("Test 30 PASSED: complex comparison true");
            pass_count++;
        end else $display("Test 30 FAILED");

        $display("PASS: comparison_ops (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
