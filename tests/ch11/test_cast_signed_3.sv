/*
:name: test_cast_signed_3
:description: Signed cast $signed
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_signed_3.expected
*/
// Signed cast $signed
module test_cast_signed;
    logic [7:0] unsigned_byte;
    logic [15:0] unsigned_half;
    logic signed [7:0] signed_byte;
    logic signed [15:0] signed_half;
    int int_result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: $signed on positive value
        unsigned_byte = 8'h7F;  // 127
        int_result = $signed(unsigned_byte);
        if (int_result == 127) begin
            $display("PASS: Test 1 - $signed on positive value");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 127, got %0d", int_result);
            fail_count++;
        end

        // Test 2: $signed on value with MSB set
        unsigned_byte = 8'h80;  // 128 unsigned, -128 signed
        int_result = $signed(unsigned_byte);
        if (int_result == -128) begin
            $display("PASS: Test 2 - $signed with MSB set");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected -128, got %0d", int_result);
            fail_count++;
        end

        // Test 3: $signed on all ones
        unsigned_byte = 8'hFF;  // 255 unsigned, -1 signed
        int_result = $signed(unsigned_byte);
        if (int_result == -1) begin
            $display("PASS: Test 3 - $signed on 0xFF");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected -1, got %0d", int_result);
            fail_count++;
        end

        // Test 4: $signed with sign extension
        unsigned_byte = 8'hF0;  // -16 as signed byte
        signed_half = $signed(unsigned_byte);
        if (signed_half == -16) begin
            $display("PASS: Test 4 - $signed with sign extension");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected -16, got %0d", signed_half);
            fail_count++;
        end

        // Test 5: Arithmetic with $signed
        unsigned_byte = 8'hFE;  // -2 as signed
        unsigned_half = 16'h0001;  // 1
        int_result = $signed(unsigned_byte) + $signed(unsigned_half);
        if (int_result == -1) begin
            $display("PASS: Test 5 - Arithmetic with $signed");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected -1, got %0d", int_result);
            fail_count++;
        end

        // Summary
        $display("Cast Signed: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
