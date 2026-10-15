/*
:name: test_system_signed
:description: $signed - signed conversion
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_signed.expected
*/
// $signed - signed conversion
module test_signed;
    logic [7:0] unsigned_val;
    logic signed [7:0] signed_result;
    logic [15:0] wide_unsigned;
    logic signed [15:0] wide_signed;
    int result;

    initial begin
        // Test 1: Convert positive value (no sign extension needed)
        unsigned_val = 8'd100;
        signed_result = $signed(unsigned_val);
        if (signed_result == 100)
            $display("PASS: $signed(8'd100) = %0d", signed_result);
        else
            $display("FAIL: $signed(8'd100) = %0d, expected 100", signed_result);

        // Test 2: Convert value with MSB set (becomes negative)
        unsigned_val = 8'hFF;  // 255 unsigned, -1 signed
        result = $signed(unsigned_val);
        if (result == -1)
            $display("PASS: $signed(8'hFF) = %0d", result);
        else
            $display("FAIL: $signed(8'hFF) = %0d, expected -1", result);

        // Test 3: Convert 0x80 (128 unsigned, -128 signed)
        unsigned_val = 8'h80;
        result = $signed(unsigned_val);
        if (result == -128)
            $display("PASS: $signed(8'h80) = %0d", result);
        else
            $display("FAIL: $signed(8'h80) = %0d, expected -128", result);

        // Test 4: Wide value conversion
        wide_unsigned = 16'hFFFF;  // 65535 unsigned, -1 signed
        result = $signed(wide_unsigned);
        if (result == -1)
            $display("PASS: $signed(16'hFFFF) = %0d", result);
        else
            $display("FAIL: $signed(16'hFFFF) = %0d, expected -1", result);

        // Test 5: Zero remains zero
        unsigned_val = 8'd0;
        result = $signed(unsigned_val);
        if (result == 0)
            $display("PASS: $signed(8'd0) = %0d", result);
        else
            $display("FAIL: $signed(8'd0) = %0d, expected 0", result);

        $finish;
    end
endmodule
