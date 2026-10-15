/*
:name: test_let_hierarchy_complex
:description: let declarations that call other let declarations, with several arguments
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_hierarchy_complex.expected
*/
// let declarations that call other let declarations, with several arguments (11.12)
module test_let_hierarchy_complex;
    int pass_count = 0;
    int test_count = 0;

    // Deep hierarchy of let declarations
    let level1(a) = a + 1;
    let level2(a) = level1(a) + 1;
    let level3(a) = level2(a) + 1;
    let level4(a) = level3(a) + 1;
    let level5(a) = level4(a) + 1;

    // Let with multiple parameters
    let combine3(a, b, c) = a + b + c;
    let combine4(a, b, c, d) = a * b + c * d;

    // Let with conditional expression
    let max2(a, b) = (a > b) ? a : b;
    let min2(a, b) = (a < b) ? a : b;
    let abs_val(x) = (x < 0) ? -x : x;

    // Let with bitwise operations
    let bit_and(a, b) = a & b;
    let bit_or(a, b) = a | b;
    let bit_xor(a, b) = a ^ b;

    initial begin
        // Test 1: Deep hierarchy call
        test_count++;
        if (level5(0) == 5) pass_count++;

        // Test 2: Level 3
        test_count++;
        if (level3(10) == 13) pass_count++;

        // Test 3: Three parameter let
        test_count++;
        if (combine3(1, 2, 3) == 6) pass_count++;

        // Test 4: Four parameter let
        test_count++;
        if (combine4(2, 3, 4, 5) == 26) pass_count++;  // 2*3 + 4*5 = 6 + 20 = 26

        // Test 5: Max function
        test_count++;
        if (max2(10, 20) == 20) pass_count++;

        // Test 6: Min function
        test_count++;
        if (min2(10, 20) == 10) pass_count++;

        // Test 7: Absolute value positive
        test_count++;
        if (abs_val(5) == 5) pass_count++;

        // Test 8: Absolute value negative
        test_count++;
        if (abs_val(-5) == 5) pass_count++;

        // Test 9: Bitwise AND
        test_count++;
        if (bit_and(8'hF0, 8'h0F) == 8'h00) pass_count++;

        // Test 10: Bitwise OR
        test_count++;
        if (bit_or(8'hF0, 8'h0F) == 8'hFF) pass_count++;

        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
