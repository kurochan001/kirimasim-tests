/*
:name: test_valueops_bitwise
:description: Bitwise AND, OR and XOR on 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_bitwise.expected
*/
// IEEE 1800-2023 §11.4: Bitwise operations
module test_valueops_bitwise;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] a, b, c;

    initial begin
        // Test 1: Bitwise AND
        a = 8'hF0;
        b = 8'h0F;
        c = a & b;
        if (c == 8'h00) begin
            $display("Test 1 PASS: AND = %02h", c);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", c);
            fail_count++;
        end

        // Test 2: Bitwise OR
        a = 8'hF0;
        b = 8'h0F;
        c = a | b;
        if (c == 8'hFF) begin
            $display("Test 2 PASS: OR = %02h", c);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", c);
            fail_count++;
        end

        // Test 3: Bitwise XOR
        a = 8'hAA;
        b = 8'hFF;
        c = a ^ b;
        if (c == 8'h55) begin
            $display("Test 3 PASS: XOR = %02h", c);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", c);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
