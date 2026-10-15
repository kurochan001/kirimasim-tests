/*
:name: test_cast_unsigned
:description: Unsigned cast $unsigned
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_unsigned.expected
*/
// Unsigned cast $unsigned
module test_cast_unsigned;
    logic signed [7:0] signed_byte;
    logic signed [15:0] signed_half;
    logic [7:0] unsigned_byte;
    logic [15:0] unsigned_half;
    logic [31:0] unsigned_word;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: $unsigned on negative value
        signed_byte = -1;  // 8'hFF
        unsigned_half = $unsigned(signed_byte);
        if (unsigned_half == 16'h00FF) begin
            $display("PASS: Test 1 - $unsigned on -1");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x00FF, got 0x%h", unsigned_half);
            fail_count++;
        end

        // Test 2: $unsigned on positive signed value
        signed_byte = 8'sh7F;  // +127
        unsigned_byte = $unsigned(signed_byte);
        if (unsigned_byte == 8'h7F) begin
            $display("PASS: Test 2 - $unsigned on positive");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0x7F, got 0x%h", unsigned_byte);
            fail_count++;
        end

        // Test 3: $unsigned prevents sign extension
        signed_byte = -128;  // 8'h80
        unsigned_word = $unsigned(signed_byte);
        if (unsigned_word == 32'h00000080) begin
            $display("PASS: Test 3 - $unsigned prevents sign extension");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0x00000080, got 0x%h", unsigned_word);
            fail_count++;
        end

        // Test 4: Comparison after $unsigned
        signed_byte = -1;  // 0xFF unsigned
        signed_half = 16'sh00FF;  // 255 signed
        if ($unsigned(signed_byte) == unsigned_half[7:0]) begin
            $display("PASS: Test 4 - Comparison after $unsigned");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Comparison failed");
            fail_count++;
        end

        // Test 5: Arithmetic with $unsigned
        signed_byte = -10;  // 246 unsigned
        signed_half = -5;   // Will become large positive
        unsigned_word = $unsigned(signed_byte) + 10;
        if (unsigned_word == 256) begin
            $display("PASS: Test 5 - Arithmetic with $unsigned");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 256, got %0d", unsigned_word);
            fail_count++;
        end

        // Summary
        $display("Cast Unsigned: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
