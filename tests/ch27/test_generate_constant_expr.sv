/*
:name: test_generate_constant_expr
:description: Generate block constant expression evaluation
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 27.6
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_constant_expr.expected
*/
// IEEE 1800-2023 §27: Generate block constant expression evaluation
// Tests:
// 1. Simple genvar iteration
// 2. Array parameter with generate index
// 3. Complex expressions with genvar
// 4. Conditional generate (if-generate)

module test_generate_constant_expr;
    // Array parameter for testing
    parameter int TEST_ARRAY[4] = '{10, 20, 30, 40};
    parameter int SIZE = 4;

    // Test signals
    logic [31:0] simple_result[SIZE];
    logic [31:0] array_result[SIZE];
    logic [31:0] complex_result[SIZE];

    // Test 1: Simple genvar iteration
    generate
        for (genvar i = 0; i < SIZE; i++) begin : gen_simple
            assign simple_result[i] = i * 10;
        end
    endgenerate

    // Test 2: Array parameter access with genvar
    generate
        for (genvar j = 0; j < SIZE; j++) begin : gen_array
            assign array_result[j] = TEST_ARRAY[j];
        end
    endgenerate

    // Test 3: Complex expression with genvar
    generate
        for (genvar k = 0; k < SIZE; k++) begin : gen_complex
            // Expression: k * 2 + 5
            assign complex_result[k] = k * 2 + 5;
        end
    endgenerate

    // Test 4: Conditional generate
    generate
        if (SIZE > 2) begin : gen_if_true
            logic condition_passed = 1;
        end else begin : gen_if_false
            logic condition_passed = 0;
        end
    endgenerate

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int expected;
        int prev_fail;
        #1;  // Let assignments settle

        // Verify Test 1: Simple genvar
        for (int idx = 0; idx < SIZE; idx++) begin
            expected = idx * 10;
            if (simple_result[idx] == expected) begin
                pass_count++;
            end else begin
                $display("FAIL: Test 1 - simple_result[%0d] = %0d, expected %0d",
                         idx, simple_result[idx], expected);
                fail_count++;
            end
        end
        if (fail_count == 0) $display("PASS: Test 1 - Simple genvar iteration");

        // Reset for next test
        prev_fail = fail_count;

        // Verify Test 2: Array parameter access
        for (int idx = 0; idx < SIZE; idx++) begin
            expected = TEST_ARRAY[idx];
            if (array_result[idx] == expected) begin
                pass_count++;
            end else begin
                $display("FAIL: Test 2 - array_result[%0d] = %0d, expected %0d",
                         idx, array_result[idx], expected);
                fail_count++;
            end
        end
        if (fail_count == prev_fail) $display("PASS: Test 2 - Array parameter access");

        prev_fail = fail_count;

        // Verify Test 3: Complex expression
        for (int idx = 0; idx < SIZE; idx++) begin
            expected = idx * 2 + 5;
            if (complex_result[idx] == expected) begin
                pass_count++;
            end else begin
                $display("FAIL: Test 3 - complex_result[%0d] = %0d, expected %0d",
                         idx, complex_result[idx], expected);
                fail_count++;
            end
        end
        if (fail_count == prev_fail) $display("PASS: Test 3 - Complex genvar expression");

        // Verify Test 4: Conditional generate
        if (gen_if_true.condition_passed == 1) begin
            $display("PASS: Test 4 - Conditional generate (if-generate)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Conditional generate");
            fail_count++;
        end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
