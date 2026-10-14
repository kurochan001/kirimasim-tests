/*
:name: test_value_operations_2
:description: Test 1: Basic arithmetic operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_operations_2.expected
*/
// IEEE 1800-2023 Section 11

module test_value_operations;
    logic [31:0] a, b, result;
    logic [63:0] wide_a, wide_b, wide_result;
    logic [7:0] byte_arr [0:3];
    real r1, r2;
    int i1, i2;

    initial begin
        // Test 1: Basic arithmetic operations
        a = 100;
        b = 25;
        result = a + b;
        if (result == 125)
            $display("PASS: Addition");
        else
            $display("FAIL: Addition got %0d", result);

        result = a - b;
        if (result == 75)
            $display("PASS: Subtraction");
        else
            $display("FAIL: Subtraction got %0d", result);

        result = a * b;
        if (result == 2500)
            $display("PASS: Multiplication");
        else
            $display("FAIL: Multiplication got %0d", result);

        result = a / b;
        if (result == 4)
            $display("PASS: Division");
        else
            $display("FAIL: Division got %0d", result);

        result = a % b;
        if (result == 0)
            $display("PASS: Modulo");
        else
            $display("FAIL: Modulo got %0d", result);

        // Test 2: Bitwise operations
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        result = a & b;
        if (result == 32'h0F000F00)
            $display("PASS: Bitwise AND");
        else
            $display("FAIL: Bitwise AND got %h", result);

        result = a | b;
        if (result == 32'hFF0FFF0F)
            $display("PASS: Bitwise OR");
        else
            $display("FAIL: Bitwise OR got %h", result);

        result = a ^ b;
        if (result == 32'hF00FF00F)
            $display("PASS: Bitwise XOR");
        else
            $display("FAIL: Bitwise XOR got %h", result);

        result = ~a;
        if (result == 32'h00FF00FF)
            $display("PASS: Bitwise NOT");
        else
            $display("FAIL: Bitwise NOT got %h", result);

        // Test 3: Shift operations
        a = 32'h00000001;
        result = a << 4;
        if (result == 32'h00000010)
            $display("PASS: Left shift");
        else
            $display("FAIL: Left shift got %h", result);

        a = 32'h80000000;
        result = a >> 4;
        if (result == 32'h08000000)
            $display("PASS: Right shift");
        else
            $display("FAIL: Right shift got %h", result);

        // Test 4: Comparison operations
        a = 100;
        b = 200;
        if (a < b)
            $display("PASS: Less than");
        else
            $display("FAIL: Less than");

        if (a <= b)
            $display("PASS: Less than or equal");
        else
            $display("FAIL: Less than or equal");

        if (b > a)
            $display("PASS: Greater than");
        else
            $display("FAIL: Greater than");

        if (b >= a)
            $display("PASS: Greater than or equal");
        else
            $display("FAIL: Greater than or equal");

        // Test 5: Equality operations
        a = 42;
        b = 42;
        if (a == b)
            $display("PASS: Equality");
        else
            $display("FAIL: Equality");

        if (a === b)
            $display("PASS: Case equality");
        else
            $display("FAIL: Case equality");

        // Test 6: Logical operations
        a = 1;
        b = 0;
        if (a && !b)
            $display("PASS: Logical AND/NOT");
        else
            $display("FAIL: Logical AND/NOT");

        if (a || b)
            $display("PASS: Logical OR");
        else
            $display("FAIL: Logical OR");

        // Test 7: Reduction operations
        a = 32'hFFFFFFFF;
        if (&a == 1'b1)
            $display("PASS: Reduction AND");
        else
            $display("FAIL: Reduction AND");

        if (|a == 1'b1)
            $display("PASS: Reduction OR");
        else
            $display("FAIL: Reduction OR");

        a = 32'h55555555;
        if (^a == 1'b0)
            $display("PASS: Reduction XOR");
        else
            $display("FAIL: Reduction XOR");

        $display("TEST PASSED: value operations completed");
        $finish;
    end
endmodule
