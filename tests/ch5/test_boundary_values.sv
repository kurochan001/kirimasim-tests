/*
:name: test_boundary_values
:description: Corner Cases - Boundary Values
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 6.11 11.4.3 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_boundary_values.expected
*/
// IEEE 1800-2023 Corner Cases - Boundary Values
// Tests edge cases with boundary values

module test_boundary_values;
    int pass_count = 0;
    int fail_count = 0;

    int signed_val;
    int unsigned uint_val;
    logic [31:0] logic_val;
    logic [63:0] large_val;
    logic [7:0] byte_val;

    initial begin
        // Test 1: Maximum positive signed int
        signed_val = 32'h7FFFFFFF;
        if (signed_val == 2147483647) begin
            $display("PASS: Max positive signed int");
            pass_count++;
        end else begin
            $display("FAIL: Max positive signed - got %0d", signed_val);
            fail_count++;
        end

        // Test 2: Minimum negative signed int
        signed_val = 32'h80000000;
        if (signed_val == -2147483648) begin
            $display("PASS: Min negative signed int");
            pass_count++;
        end else begin
            $display("FAIL: Min negative signed - got %0d", signed_val);
            fail_count++;
        end

        // Test 3: Signed overflow behavior
        signed_val = 32'h7FFFFFFF;
        signed_val = signed_val + 1;
        if (signed_val < 0) begin
            $display("PASS: Signed overflow wraps to negative");
            pass_count++;
        end else begin
            $display("FAIL: Signed overflow - got %0d", signed_val);
            fail_count++;
        end

        // Test 4: Zero edge cases
        byte_val = 8'd0;
        if (byte_val == 0 && !byte_val && ~byte_val == 8'hFF) begin
            $display("PASS: Zero edge cases");
            pass_count++;
        end else begin
            $display("FAIL: Zero edge cases");
            fail_count++;
        end

        // Test 5: All ones
        byte_val = 8'hFF;
        if (byte_val == 255 && byte_val && ~byte_val == 8'h00) begin
            $display("PASS: All ones (0xFF)");
            pass_count++;
        end else begin
            $display("FAIL: All ones - got %h", byte_val);
            fail_count++;
        end

        // Test 6: Power of 2 boundaries
        logic_val = 32'h1;
        for (int i = 0; i < 31; i++) begin
            if (logic_val != (1 << i)) begin
                $display("FAIL: Power of 2 at shift %0d", i);
                fail_count++;
            end
            logic_val = logic_val << 1;
        end
        $display("PASS: Power of 2 boundaries");
        pass_count++;

        // Test 7: 64-bit large value
        large_val = 64'hFFFFFFFF_FFFFFFFF;
        if (large_val + 1 == 0) begin
            $display("PASS: 64-bit wrap around");
            pass_count++;
        end else begin
            $display("FAIL: 64-bit wrap");
            fail_count++;
        end

        // Test 8: Bit patterns
        logic_val = 32'hAAAA_AAAA;
        if ((logic_val ^ 32'h5555_5555) == 32'hFFFF_FFFF) begin
            $display("PASS: Alternating bit pattern XOR");
            pass_count++;
        end else begin
            $display("FAIL: Bit pattern XOR");
            fail_count++;
        end

        $display("");
        $display("=== Boundary Values Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
