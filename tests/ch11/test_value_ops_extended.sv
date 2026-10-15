/*
:name: test_value_ops_extended
:description: Arithmetic on 32-bit vectors, with a 64-bit context for a product
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_ops_extended.expected
*/
// Arithmetic on 32-bit vectors, with a 64-bit context for a product
// IEEE 1800-2023 §11.4

module test_value_ops_extended;
    logic [31:0] a, b, result;
    logic [63:0] wide;
    int i, j;
    real r1, r2;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Unsigned addition
        test_count++;
        a = 100;
        b = 200;
        result = a + b;
        if (result == 300) begin
            $display("Test 1: 100 + 200 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 1: 100 + 200 = %0d FAIL", result);
        end

        // Test 2: Unsigned subtraction with underflow
        test_count++;
        a = 100;
        b = 200;
        result = a - b;
        if (result == 32'hFFFFFF9C) begin
            $display("Test 2: 100 - 200 = 0x%h PASS", result);
            pass_count++;
        end else begin
            $display("Test 2: 100 - 200 = 0x%h FAIL", result);
        end

        // Test 3: Multiplication
        test_count++;
        a = 1000;
        b = 1000;
        result = a * b;
        if (result == 1000000) begin
            $display("Test 3: 1000 * 1000 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 3: 1000 * 1000 = %0d FAIL", result);
        end

        // Test 4: Division
        test_count++;
        a = 100;
        b = 3;
        result = a / b;
        if (result == 33) begin
            $display("Test 4: 100 / 3 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 4: 100 / 3 = %0d FAIL", result);
        end

        // Test 5: Modulo
        test_count++;
        a = 100;
        b = 7;
        result = a % b;
        if (result == 2) begin
            $display("Test 5: 100 %% 7 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 5: 100 %% 7 = %0d FAIL", result);
        end

        // Test 6: Power
        test_count++;
        a = 2;
        b = 10;
        result = a ** b;
        if (result == 1024) begin
            $display("Test 6: 2 ** 10 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 6: 2 ** 10 = %0d FAIL", result);
        end

        // Test 7: Wide multiplication
        test_count++;
        a = 32'hFFFFFFFF;
        b = 2;
        wide = a * b;
        if (wide == 64'h1FFFFFFFE) begin
            $display("Test 7: 0xFFFFFFFF * 2 = 0x%h PASS", wide);
            pass_count++;
        end else begin
            $display("Test 7: 0xFFFFFFFF * 2 = 0x%h FAIL", wide);
        end

        // Test 8: Signed arithmetic
        test_count++;
        i = -10;
        j = 3;
        i = i / j;
        if (i == -3) begin
            $display("Test 8: -10 / 3 = %0d PASS", i);
            pass_count++;
        end else begin
            $display("Test 8: -10 / 3 = %0d FAIL", i);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
