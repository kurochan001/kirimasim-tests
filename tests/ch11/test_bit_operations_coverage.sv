/*
:name: test_bit_operations_coverage
:description: Bit operations coverage test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8 11.4.9 11.4.10 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_operations_coverage.expected
*/
// IEEE 1800-2023 Section 11.4 - Bit operations coverage test
// Tests: bitwise, reduction, shift operations
module test_bit_operations_coverage;
    int passed = 0;
    int failed = 0;

    logic [7:0] a, b, result;
    logic [15:0] wide;

    initial begin
        // Test bitwise AND
        a = 8'hF0;
        b = 8'h0F;
        result = a & b;
        if (result == 8'h00) passed++; else begin failed++; $display("FAIL: AND"); end

        // Test bitwise OR
        result = a | b;
        if (result == 8'hFF) passed++; else begin failed++; $display("FAIL: OR"); end

        // Test bitwise XOR
        result = a ^ b;
        if (result == 8'hFF) passed++; else begin failed++; $display("FAIL: XOR"); end

        // Test bitwise NOT
        result = ~a;
        if (result == 8'h0F) passed++; else begin failed++; $display("FAIL: NOT"); end

        // Test bitwise NAND
        result = ~(a & b);
        if (result == 8'hFF) passed++; else begin failed++; $display("FAIL: NAND"); end

        // Test bitwise NOR
        result = ~(a | b);
        if (result == 8'h00) passed++; else begin failed++; $display("FAIL: NOR"); end

        // Test bitwise XNOR
        result = ~(a ^ b);
        if (result == 8'h00) passed++; else begin failed++; $display("FAIL: XNOR"); end

        // Test reduction AND
        a = 8'hFF;
        if (&a == 1'b1) passed++; else begin failed++; $display("FAIL: reduction AND"); end

        // Test reduction OR
        a = 8'h01;
        if (|a == 1'b1) passed++; else begin failed++; $display("FAIL: reduction OR"); end

        // Test reduction XOR
        a = 8'h03; // 00000011 - 2 ones = even parity
        if (^a == 1'b0) passed++; else begin failed++; $display("FAIL: reduction XOR = %b", ^a); end

        // Test left shift
        a = 8'h01;
        result = a << 4;
        if (result == 8'h10) passed++; else begin failed++; $display("FAIL: left shift"); end

        // Test right shift
        a = 8'h80;
        result = a >> 4;
        if (result == 8'h08) passed++; else begin failed++; $display("FAIL: right shift"); end

        // Test arithmetic right shift
        begin
            logic signed [7:0] sa;
            logic signed [7:0] sr;
            sa = -8;  // 11111000
            sr = sa >>> 2;
            if (sr == -2) passed++; else begin failed++; $display("FAIL: arith shift = %0d", sr); end
        end

        // Test left shift with variable
        begin
            static int shift_amt = 3;
            result = 8'h01 << shift_amt;
            if (result == 8'h08) passed++; else begin failed++; $display("FAIL: var shift"); end
        end

        // Test part select
        wide = 16'hABCD;
        if (wide[7:0] == 8'hCD) passed++; else begin failed++; $display("FAIL: part select"); end
        if (wide[15:8] == 8'hAB) passed++; else begin failed++; $display("FAIL: part select hi"); end

        // Test indexed part select +
        if (wide[0 +: 8] == 8'hCD) passed++; else begin failed++; $display("FAIL: indexed +"); end

        // Test indexed part select -
        if (wide[15 -: 8] == 8'hAB) passed++; else begin failed++; $display("FAIL: indexed -"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d bit operation tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
