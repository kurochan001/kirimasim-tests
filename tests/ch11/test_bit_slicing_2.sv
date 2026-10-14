/*
:name: test_bit_slicing_2
:description: Bit Slicing Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_slicing_2.expected
*/
// IEEE 1800-2023 Section 11.5 - Bit Slicing Tests
// Tests: Part select, indexed part select, variable part select

module test_bit_slicing;
    int pass_count = 0;
    int fail_count = 0;

    logic [31:0] data32;
    logic [63:0] data64;
    logic [7:0] byte_val;
    int idx;

    initial begin
        $display("=== IEEE 1800-2023 Bit Slicing Tests ===");

        // Test 1: Constant part select
        $display("Test 1: Constant part select");
        data32 = 32'h12345678;
        if (data32[15:8] == 8'h56) begin
            $display("Test 1 PASS: data32[15:8]=%h", data32[15:8]);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: data32[15:8]=%h", data32[15:8]);
            fail_count++;
        end

        // Test 2: Single bit select
        $display("Test 2: Single bit select");
        data32 = 32'h80000000;
        if (data32[31] == 1'b1) begin
            $display("Test 2 PASS: data32[31]=%b", data32[31]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Indexed part select ascending +:
        $display("Test 3: Indexed part select +:");
        data32 = 32'hDEADBEEF;
        idx = 8;
        byte_val = data32[idx+:8];  // bits [15:8]
        if (byte_val == 8'hBE) begin
            $display("Test 3 PASS: data32[8+:8]=%h", byte_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", byte_val);
            fail_count++;
        end

        // Test 4: Indexed part select descending -:
        $display("Test 4: Indexed part select -:");
        data32 = 32'hCAFEBABE;
        idx = 23;
        byte_val = data32[idx-:8];  // bits [23:16]
        if (byte_val == 8'hFE) begin
            $display("Test 4 PASS: data32[23-:8]=%h", byte_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", byte_val);
            fail_count++;
        end

        // Test 5: Upper bits extraction
        $display("Test 5: Upper bits extraction");
        data32 = 32'hABCDEF01;
        if (data32[31:24] == 8'hAB) begin
            $display("Test 5 PASS: data32[31:24]=%h", data32[31:24]);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Lower bits extraction
        $display("Test 6: Lower bits extraction");
        if (data32[7:0] == 8'h01) begin
            $display("Test 6 PASS: data32[7:0]=%h", data32[7:0]);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: 64-bit value slicing
        $display("Test 7: 64-bit value slicing");
        data64 = 64'h0123456789ABCDEF;
        if (data64[47:32] == 16'h4567) begin
            $display("Test 7 PASS: data64[47:32]=%h", data64[47:32]);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Variable index bit select
        $display("Test 8: Variable index bit select");
        data32 = 32'h00000001;
        idx = 0;
        if (data32[idx] == 1'b1) begin
            $display("Test 8 PASS: data32[0]=%b", data32[idx]);
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
