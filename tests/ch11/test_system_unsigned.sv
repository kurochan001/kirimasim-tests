/*
:name: test_system_unsigned
:description: $unsigned - unsigned conversion
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_unsigned.expected
*/
// $unsigned - unsigned conversion
module test_unsigned;
    logic signed [7:0] signed_val;
    logic [7:0] unsigned_result;
    logic signed [15:0] wide_signed;
    int result;

    initial begin
        // Test 1: Convert positive signed value
        signed_val = 8'sd100;
        result = $unsigned(signed_val);
        if (result == 100)
            $display("PASS: $unsigned(8'sd100) = %0d", result);
        else
            $display("FAIL: $unsigned(8'sd100) = %0d, expected 100", result);

        // Test 2: Convert -1 (becomes 255 in 8-bit)
        signed_val = -8'sd1;
        unsigned_result = $unsigned(signed_val);
        if (unsigned_result == 8'd255)
            $display("PASS: $unsigned(-1) = %0d", unsigned_result);
        else
            $display("FAIL: $unsigned(-1) = %0d, expected 255", unsigned_result);

        // Test 3: Convert -128 (becomes 128 in 8-bit)
        signed_val = -8'sd128;
        unsigned_result = $unsigned(signed_val);
        if (unsigned_result == 8'd128)
            $display("PASS: $unsigned(-128) = %0d", unsigned_result);
        else
            $display("FAIL: $unsigned(-128) = %0d, expected 128", unsigned_result);

        // Test 4: Wide signed value
        wide_signed = -16'sd1;
        result = $unsigned(wide_signed);
        if (result == 65535)
            $display("PASS: $unsigned(16'sd-1) = %0d", result);
        else
            $display("FAIL: $unsigned(16'sd-1) = %0d, expected 65535", result);

        // Test 5: Zero remains zero
        signed_val = 8'sd0;
        result = $unsigned(signed_val);
        if (result == 0)
            $display("PASS: $unsigned(8'sd0) = %0d", result);
        else
            $display("FAIL: $unsigned(8'sd0) = %0d, expected 0", result);

        $finish;
    end
endmodule
