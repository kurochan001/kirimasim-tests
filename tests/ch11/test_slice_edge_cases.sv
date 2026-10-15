/*
:name: test_slice_edge_cases
:description: Reading and writing bit-selects and constant and indexed part-selects
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_slice_edge_cases.expected
*/
// IEEE 1800-2023 §11.5: Part-select edge cases
// Tests for bit and part select operators

module test_slice_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [31:0] data;
    logic [7:0] byte_val;
    logic [3:0] nibble;
    logic single_bit;

    initial begin
        // Test 1: Single bit select
        test_count++;
        data = 32'h80000000;
        single_bit = data[31];
        if (single_bit == 1) begin
            pass_count++;
            $display("Test 1 PASS: data[31] = %b", single_bit);
        end else begin
            $display("Test 1 FAIL: Bit unexpected = %b", single_bit);
        end

        // Test 2: Byte select
        test_count++;
        data = 32'hAABBCCDD;
        byte_val = data[31:24];
        if (byte_val == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: data[31:24] = %h", byte_val);
        end else begin
            $display("Test 2 FAIL: Byte unexpected = %h", byte_val);
        end

        // Test 3: Low byte
        test_count++;
        byte_val = data[7:0];
        if (byte_val == 8'hDD) begin
            pass_count++;
            $display("Test 3 PASS: data[7:0] = %h", byte_val);
        end else begin
            $display("Test 3 FAIL: Low unexpected = %h", byte_val);
        end

        // Test 4: Nibble select
        test_count++;
        data = 32'h12345678;
        nibble = data[7:4];
        if (nibble == 4'h7) begin
            pass_count++;
            $display("Test 4 PASS: data[7:4] = %h", nibble);
        end else begin
            $display("Test 4 FAIL: Nibble unexpected = %h", nibble);
        end

        // Test 5: Variable bit select
        test_count++;
        begin
            static int idx = 16;
            single_bit = data[idx];
            // Bit 16 of 32'h12345678 is 0.
            if (single_bit == 1'b0) begin
                pass_count++;
                $display("Test 5 PASS: data[%0d] = %b", idx, single_bit);
            end else begin
                $display("Test 5 FAIL: data[%0d] = %b", idx, single_bit);
            end
        end

        // Test 6: Variable part select +
        test_count++;
        begin
            static int start = 8;
            byte_val = data[start +: 8];
            if (byte_val == 8'h56) begin
                pass_count++;
                $display("Test 6 PASS: data[8+:8] = %h", byte_val);
            end else begin
                $display("Test 6 FAIL: +: unexpected = %h", byte_val);
            end
        end

        // Test 7: Variable part select -
        test_count++;
        begin
            static int start = 23;
            byte_val = data[start -: 8];
            if (byte_val == 8'h34) begin
                pass_count++;
                $display("Test 7 PASS: data[23-:8] = %h", byte_val);
            end else begin
                $display("Test 7 FAIL: -: unexpected = %h", byte_val);
            end
        end

        // Test 8: All zeros
        test_count++;
        data = 32'h00000000;
        byte_val = data[15:8];
        if (byte_val == 8'h00) begin
            pass_count++;
            $display("Test 8 PASS: Zero slice = %h", byte_val);
        end else begin
            $display("Test 8 FAIL: Zero unexpected = %h", byte_val);
        end

        // Test 9: All ones
        test_count++;
        data = 32'hFFFFFFFF;
        byte_val = data[23:16];
        if (byte_val == 8'hFF) begin
            pass_count++;
            $display("Test 9 PASS: Ones slice = %h", byte_val);
        end else begin
            $display("Test 9 FAIL: Ones unexpected = %h", byte_val);
        end

        // Test 10: Write via slice
        test_count++;
        data = 32'h00000000;
        data[15:8] = 8'hAB;
        if (data == 32'h0000AB00) begin
            pass_count++;
            $display("Test 10 PASS: Write slice = %h", data);
        end else begin
            $display("Test 10 FAIL: Write unexpected = %h", data);
        end

        // Test 11: Single bit write
        test_count++;
        data = 32'h00000000;
        data[0] = 1;
        if (data == 32'h00000001) begin
            pass_count++;
            $display("Test 11 PASS: Bit write = %h", data);
        end else begin
            $display("Test 11 FAIL: Bit write unexpected = %h", data);
        end

        // Test 12: Cross byte boundary
        test_count++;
        data = 32'h12345678;
        begin
            static logic [15:0] word;
            // Assigned here so the result does not depend on the order of static initializers.
            word = data[19:4];
            if (word == 16'h4567) begin
                pass_count++;
                $display("Test 12 PASS: Cross boundary = %h", word);
            end else begin
                $display("Test 12 FAIL: Cross boundary = %h", word);
            end
        end

        $display("=== Slice Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
