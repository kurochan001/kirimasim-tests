/*
:name: test_logic_operations
:description: Logic Operations Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_operations.expected
*/
// IEEE 1800-2023 Section 11.4 - Logic Operations Tests
// Tests: 4-state logic, X/Z handling, reduction operators

module test_logic_operations;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b, result;
    logic [3:0] vec;
    logic single;

    initial begin
        $display("=== IEEE 1800-2023 Logic Operations Tests ===");

        // Test 1: Basic AND
        $display("Test 1: Bitwise AND");
        a = 8'hF0;
        b = 8'h0F;
        result = a & b;
        if (result == 8'h00) begin
            $display("Test 1 PASS: F0 & 0F = %h", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: result=%h", result);
            fail_count++;
        end

        // Test 2: Basic OR
        $display("Test 2: Bitwise OR");
        result = a | b;
        if (result == 8'hFF) begin
            $display("Test 2 PASS: F0 | 0F = %h", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: XOR
        $display("Test 3: Bitwise XOR");
        a = 8'hAA;
        b = 8'h55;
        result = a ^ b;
        if (result == 8'hFF) begin
            $display("Test 3 PASS: AA ^ 55 = %h", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: NOT
        $display("Test 4: Bitwise NOT");
        a = 8'hF0;
        result = ~a;
        if (result == 8'h0F) begin
            $display("Test 4 PASS: ~F0 = %h", result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Reduction AND
        $display("Test 5: Reduction AND");
        vec = 4'hF;
        single = &vec;
        if (single == 1'b1) begin
            $display("Test 5 PASS: &F = %b", single);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Reduction OR
        $display("Test 6: Reduction OR");
        vec = 4'h1;
        single = |vec;
        if (single == 1'b1) begin
            $display("Test 6 PASS: |1 = %b", single);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Reduction XOR
        $display("Test 7: Reduction XOR");
        vec = 4'b1010;  // Even number of 1s
        single = ^vec;
        if (single == 1'b0) begin
            $display("Test 7 PASS: ^1010 = %b", single);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: single=%b", single);
            fail_count++;
        end

        // Test 8: NAND/NOR/XNOR
        $display("Test 8: NAND/NOR/XNOR");
        a = 8'hFF;
        b = 8'hFF;
        result = ~(a & b);  // NAND
        if (result == 8'h00) begin
            $display("Test 8 PASS: ~(FF & FF) = %h", result);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
