/*
:name: test_binary_logical
:description: Logical and bitwise operators on 1-bit, vector and int operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_binary_logical.expected
*/
// Logical and bitwise operators on 1-bit, vector and int operands

module test_binary_logical;
    int pass_count = 0;
    int total_tests = 25;

    // Test variables
    logic a, b;
    logic [7:0] va, vb, vresult;
    logic [31:0] wa, wb;
    int ia, ib;

    initial begin
        // Test 1: Logical AND - true && true
        a = 1'b1; b = 1'b1;
        if ((a && b) == 1'b1) begin
            $display("Test 1 PASSED: 1 && 1 = 1");
            pass_count++;
        end else $display("Test 1 FAILED: 1 && 1 = %b", a && b);

        // Test 2: Logical AND - true && false
        a = 1'b1; b = 1'b0;
        if ((a && b) == 1'b0) begin
            $display("Test 2 PASSED: 1 && 0 = 0");
            pass_count++;
        end else $display("Test 2 FAILED: 1 && 0 = %b", a && b);

        // Test 3: Logical AND - false && false
        a = 1'b0; b = 1'b0;
        if ((a && b) == 1'b0) begin
            $display("Test 3 PASSED: 0 && 0 = 0");
            pass_count++;
        end else $display("Test 3 FAILED: 0 && 0 = %b", a && b);

        // Test 4: Logical OR - true || false
        a = 1'b1; b = 1'b0;
        if ((a || b) == 1'b1) begin
            $display("Test 4 PASSED: 1 || 0 = 1");
            pass_count++;
        end else $display("Test 4 FAILED: 1 || 0 = %b", a || b);

        // Test 5: Logical OR - false || false
        a = 1'b0; b = 1'b0;
        if ((a || b) == 1'b0) begin
            $display("Test 5 PASSED: 0 || 0 = 0");
            pass_count++;
        end else $display("Test 5 FAILED: 0 || 0 = %b", a || b);

        // Test 6: Bitwise AND
        va = 8'hF0; vb = 8'h0F;
        vresult = va & vb;
        if (vresult == 8'h00) begin
            $display("Test 6 PASSED: 0xF0 & 0x0F = 0x00");
            pass_count++;
        end else $display("Test 6 FAILED: 0xF0 & 0x0F = %h", vresult);

        // Test 7: Bitwise AND - overlapping bits
        va = 8'hAA; vb = 8'hCC;
        vresult = va & vb;
        if (vresult == 8'h88) begin
            $display("Test 7 PASSED: 0xAA & 0xCC = 0x88");
            pass_count++;
        end else $display("Test 7 FAILED: 0xAA & 0xCC = %h", vresult);

        // Test 8: Bitwise OR
        va = 8'hF0; vb = 8'h0F;
        vresult = va | vb;
        if (vresult == 8'hFF) begin
            $display("Test 8 PASSED: 0xF0 | 0x0F = 0xFF");
            pass_count++;
        end else $display("Test 8 FAILED: 0xF0 | 0x0F = %h", vresult);

        // Test 9: Bitwise OR - partial overlap
        va = 8'hA0; vb = 8'h05;
        vresult = va | vb;
        if (vresult == 8'hA5) begin
            $display("Test 9 PASSED: 0xA0 | 0x05 = 0xA5");
            pass_count++;
        end else $display("Test 9 FAILED: 0xA0 | 0x05 = %h", vresult);

        // Test 10: Bitwise XOR
        va = 8'hFF; vb = 8'hAA;
        vresult = va ^ vb;
        if (vresult == 8'h55) begin
            $display("Test 10 PASSED: 0xFF ^ 0xAA = 0x55");
            pass_count++;
        end else $display("Test 10 FAILED: 0xFF ^ 0xAA = %h", vresult);

        // Test 11: Bitwise XOR - same value
        va = 8'h5A; vb = 8'h5A;
        vresult = va ^ vb;
        if (vresult == 8'h00) begin
            $display("Test 11 PASSED: 0x5A ^ 0x5A = 0x00");
            pass_count++;
        end else $display("Test 11 FAILED: 0x5A ^ 0x5A = %h", vresult);

        // Test 12: Logical AND with integers (non-zero)
        ia = 42; ib = 100;
        if ((ia && ib) == 1'b1) begin
            $display("Test 12 PASSED: 42 && 100 = 1");
            pass_count++;
        end else $display("Test 12 FAILED: 42 && 100 = %b", ia && ib);

        // Test 13: Logical AND with zero
        ia = 42; ib = 0;
        if ((ia && ib) == 1'b0) begin
            $display("Test 13 PASSED: 42 && 0 = 0");
            pass_count++;
        end else $display("Test 13 FAILED: 42 && 0 = %b", ia && ib);

        // Test 14: Logical OR with integers
        ia = 0; ib = 100;
        if ((ia || ib) == 1'b1) begin
            $display("Test 14 PASSED: 0 || 100 = 1");
            pass_count++;
        end else $display("Test 14 FAILED: 0 || 100 = %b", ia || ib);

        // Test 15: 32-bit bitwise AND
        wa = 32'hFFFF0000; wb = 32'h0000FFFF;
        if ((wa & wb) == 32'h00000000) begin
            $display("Test 15 PASSED: 0xFFFF0000 & 0x0000FFFF = 0");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: 32-bit bitwise OR
        wa = 32'hFF00FF00; wb = 32'h00FF00FF;
        if ((wa | wb) == 32'hFFFFFFFF) begin
            $display("Test 16 PASSED: 0xFF00FF00 | 0x00FF00FF = 0xFFFFFFFF");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: 32-bit bitwise XOR
        wa = 32'hAAAAAAAA; wb = 32'hFFFFFFFF;
        if ((wa ^ wb) == 32'h55555555) begin
            $display("Test 17 PASSED: 0xAAAAAAAA ^ 0xFFFFFFFF = 0x55555555");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Chained logical AND
        a = 1'b1;
        if ((a && a && a) == 1'b1) begin
            $display("Test 18 PASSED: 1 && 1 && 1 = 1");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Chained logical OR
        a = 1'b0;
        if ((a || a || 1'b1) == 1'b1) begin
            $display("Test 19 PASSED: 0 || 0 || 1 = 1");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Mixed logical operators
        a = 1'b1; b = 1'b0;
        if (((a && b) || (a && a)) == 1'b1) begin
            $display("Test 20 PASSED: (1 && 0) || (1 && 1) = 1");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Bitwise with all ones
        va = 8'hFF;
        if ((va & 8'hFF) == 8'hFF) begin
            $display("Test 21 PASSED: 0xFF & 0xFF = 0xFF");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Bitwise with all zeros
        va = 8'h00;
        if ((va | 8'h00) == 8'h00) begin
            $display("Test 22 PASSED: 0x00 | 0x00 = 0x00");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: XOR self gives zero
        va = 8'hAB;
        if ((va ^ va) == 8'h00) begin
            $display("Test 23 PASSED: 0xAB ^ 0xAB = 0x00");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: XOR with zero gives self
        va = 8'h42;
        if ((va ^ 8'h00) == 8'h42) begin
            $display("Test 24 PASSED: 0x42 ^ 0x00 = 0x42");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Complex expression
        va = 8'hAA; vb = 8'h55;
        vresult = (va & vb) | (va ^ vb);
        if (vresult == 8'hFF) begin
            $display("Test 25 PASSED: (0xAA & 0x55) | (0xAA ^ 0x55) = 0xFF");
            pass_count++;
        end else $display("Test 25 FAILED: result = %h", vresult);

        $display("PASS: binary_logical (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
