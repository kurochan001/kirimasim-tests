/*
:name: test_complex_condition_2
:description: Conditions combining logical, relational and arithmetic operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_complex_condition_2.expected
*/
// Test: Complex conditions combining logical, relational and arithmetic operators
module test_complex_condition;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b, c, d;
    logic result;

    initial begin
        a = 8'h10;
        b = 8'h20;
        c = 8'h30;
        d = 8'h40;

        // Test 1: Simple AND
        test_count++;
        result = (a < b) && (c < d);
        if (result) pass_count++;

        // Test 2: Simple OR
        test_count++;
        result = (a > b) || (c < d);
        if (result) pass_count++;

        // Test 3: Complex AND-OR
        test_count++;
        result = (a < b) && (c < d) || (a == 8'h10);
        if (result) pass_count++;

        // Test 4: Nested conditions
        test_count++;
        result = ((a < b) && (b < c)) && ((c < d) || (a == 8'h00));
        if (result) pass_count++;

        // Test 5: NOT operator
        test_count++;
        result = !(a > b);
        if (result) pass_count++;

        // Test 6: Mixed operators
        test_count++;
        result = (a + b < c + d) && (a * 2 == b);
        if (result) pass_count++;

        // Test 7: Bitwise in condition
        test_count++;
        result = ((a & 8'hF0) == 8'h10) && ((b | 8'h0F) == 8'h2F);
        if (result) pass_count++;

        // Test 8: Ternary in condition
        test_count++;
        result = (a < b) ? (c < d) : (c > d);
        if (result) pass_count++;

        // Test 9: Equality chain
        test_count++;
        result = (a != b) && (b != c) && (c != d);
        if (result) pass_count++;

        // Test 10: Complex expression
        test_count++;
        result = ((a + b + c + d) == 8'hA0) && ((d - c) == (c - b)) && ((b - a) == 8'h10);
        if (result) pass_count++;

        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
