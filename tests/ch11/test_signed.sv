/*
:name: test_signed
:description: Signed/unsigned conversion
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.7 11.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed.expected
*/
// IEEE 1800-2023 Section 11.7: Signed/unsigned conversion
module test_signed;
    logic [7:0] unsigned_val;
    logic signed [7:0] signed_val;
    int result;

    initial begin
        // $signed
        unsigned_val = 8'hFF;  // 255 unsigned
        result = $signed(unsigned_val);
        if (result == -1)
            $display("PASS: $signed(0xFF) = -1");
        else
            $display("FAIL: signed = %0d", result);

        // $unsigned
        signed_val = -1;  // 0xFF
        result = $unsigned(signed_val);
        if (result == 255)
            $display("PASS: $unsigned(-1) = 255");
        else
            $display("FAIL: unsigned = %0d", result);

        // Mixed operations
        unsigned_val = 8'h80;  // 128 unsigned, -128 signed
        result = $signed(unsigned_val);
        if (result == -128)
            $display("PASS: $signed(0x80) = -128");
        else
            $display("FAIL: signed80 = %0d", result);

        $display("TEST PASSED: signed/unsigned tests completed");
        $finish;
    end
endmodule
