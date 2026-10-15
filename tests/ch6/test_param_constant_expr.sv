/*
:name: test_param_constant_expr
:description: Parameters and localparams defined by constant expressions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 6.20.4 11.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_constant_expr.expected
*/
// Parameters and localparams defined by constant expressions
module test_param_constant_expr;
    int pass_count = 0;
    int test_count = 0;

    // Constant parameters
    parameter A = 10;
    parameter B = 20;
    parameter C = A + B;
    parameter D = A * B;
    parameter E = C + D;

    // Localparam
    localparam L1 = 100;
    localparam L2 = L1 * 2;
    localparam L3 = L2 / 10;

    // Constant expressions
    localparam logic [7:0] BYTE_CONST = 8'hAB;
    localparam logic [15:0] WORD_CONST = {BYTE_CONST, 8'hCD};

    // Array of constants
    localparam int ARR[4] = '{1, 2, 3, 4};

    initial begin
        // Test 1: Simple parameter
        test_count++;
        if (A == 10) pass_count++;

        // Test 2: Parameter sum
        test_count++;
        if (C == 30) pass_count++;

        // Test 3: Parameter product
        test_count++;
        if (D == 200) pass_count++;

        // Test 4: Compound expression
        test_count++;
        if (E == 230) pass_count++;

        // Test 5: Localparam
        test_count++;
        if (L1 == 100) pass_count++;

        // Test 6: Localparam chain
        test_count++;
        if (L2 == 200) pass_count++;

        // Test 7: Localparam division
        test_count++;
        if (L3 == 20) pass_count++;

        // Test 8: Byte constant
        test_count++;
        if (BYTE_CONST == 8'hAB) pass_count++;

        // Test 9: Concatenation constant
        test_count++;
        if (WORD_CONST == 16'hABCD) pass_count++;

        // Test 10: Array constant
        test_count++;
        if (ARR[0] == 1 && ARR[3] == 4) pass_count++;

        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
