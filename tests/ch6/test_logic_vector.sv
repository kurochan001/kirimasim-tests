/*
:name: test_logic_vector
:description: Logic Vector Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_vector.expected
*/
// IEEE 1800-2023 Section 6.9 - Logic Vector Tests
module test_logic_vector;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] a, b, result;
        logic [15:0] wide;

        $display("=== IEEE 1800-2023 Logic Vector Tests ===");

        // Test 1: Assign value
        $display("Test 1: Assign");
        a = 8'hAB;
        if (a == 8'hAB) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", a); fail_count++; end

        // Test 2: Add vectors
        $display("Test 2: Add");
        a = 8'h10;
        b = 8'h05;
        result = a + b;
        if (result == 8'h15) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", result); fail_count++; end

        // Test 3: AND vectors
        $display("Test 3: AND");
        a = 8'hFF;
        b = 8'h0F;
        result = a & b;
        if (result == 8'h0F) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", result); fail_count++; end

        // Test 4: OR vectors
        $display("Test 4: OR");
        a = 8'hF0;
        b = 8'h0F;
        result = a | b;
        if (result == 8'hFF) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", result); fail_count++; end

        // Test 5: XOR vectors
        $display("Test 5: XOR");
        a = 8'hFF;
        b = 8'h0F;
        result = a ^ b;
        if (result == 8'hF0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", result); fail_count++; end

        // Test 6: NOT vector
        $display("Test 6: NOT");
        a = 8'h00;
        result = ~a;
        if (result == 8'hFF) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", result); fail_count++; end

        // Test 7: Shift left
        $display("Test 7: Shift left");
        a = 8'h01;
        result = a << 4;
        if (result == 8'h10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", result); fail_count++; end

        // Test 8: Shift right
        $display("Test 8: Shift right");
        a = 8'h80;
        result = a >> 4;
        if (result == 8'h08) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
