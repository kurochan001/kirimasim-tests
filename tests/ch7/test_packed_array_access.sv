/*
:name: test_packed_array_access
:description: Packed Array Bit/Slice Access Test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_access.expected
*/
// IEEE 1800-2023 §7.4 Packed Array Bit/Slice Access Test

module test_packed_array_access;
    logic [7:0] byte_val;
    logic [3:0] nibble;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Packed Array Bit/Slice Access Test (IEEE 1800-2023 §7.4) ===");

        // Test 1: Bit access on logic vector
        byte_val = 8'b10101010;
        if (byte_val[0] == 1'b0) begin
            $display("PASS: byte_val[0] = 0");
            passed++;
        end else begin
            $display("FAIL: byte_val[0] = %b, expected 0", byte_val[0]);
            failed++;
        end

        // Test 2: Bit access higher bit
        if (byte_val[7] == 1'b1) begin
            $display("PASS: byte_val[7] = 1");
            passed++;
        end else begin
            $display("FAIL: byte_val[7] = %b, expected 1", byte_val[7]);
            failed++;
        end

        // Test 3: Slice access
        nibble = byte_val[3:0];
        if (nibble == 4'b1010) begin
            $display("PASS: byte_val[3:0] = 4'b1010");
            passed++;
        end else begin
            $display("FAIL: byte_val[3:0] = %b, expected 1010", nibble);
            failed++;
        end

        // Test 4: Upper slice
        nibble = byte_val[7:4];
        if (nibble == 4'b1010) begin
            $display("PASS: byte_val[7:4] = 4'b1010");
            passed++;
        end else begin
            $display("FAIL: byte_val[7:4] = %b, expected 1010", nibble);
            failed++;
        end

        // Test 5: Bit assignment
        byte_val[0] = 1'b1;
        if (byte_val == 8'b10101011) begin
            $display("PASS: byte_val after [0]=1 is 8'b10101011");
            passed++;
        end else begin
            $display("FAIL: byte_val = %b, expected 10101011", byte_val);
            failed++;
        end

        // Test 6: Slice assignment
        byte_val = 8'h00;
        byte_val[3:0] = 4'b1111;
        if (byte_val == 8'b00001111) begin
            $display("PASS: byte_val[3:0]=4'b1111 gives 8'b00001111");
            passed++;
        end else begin
            $display("FAIL: byte_val = %b, expected 00001111", byte_val);
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
