/*
:name: test_streaming_nested
:description: Multiple streaming operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_nested.expected
*/
// IEEE 1800-2023 §11.4.14: Multiple streaming operations
module test_streaming_nested;
    logic [31:0] data;
    logic [7:0] a, b, c, d;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack then swap bytes
        a = 8'hAA; b = 8'hBB; c = 8'hCC; d = 8'hDD;
        data = {>>{a, b, c, d}};
        // data should be AABBCCDD
        data = {<<8{data}};
        // After swap should be DDCCBBAA
        if (data == 32'hDDCCBBAA) begin
            $display("Test 1 PASS: pack+swap = %08h", data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", data);
            fail_count++;
        end

        // Test 2: Double swap returns original
        data = 32'h12345678;
        data = {<<8{data}};  // Swap: 78563412
        data = {<<8{data}};  // Swap back: 12345678
        if (data == 32'h12345678) begin
            $display("Test 2 PASS: double swap = %08h", data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", data);
            fail_count++;
        end

        // Test 3: Swap symmetric value
        data = 32'hABCDDCBA;  // Symmetric pattern
        data = {<<8{data}};  // Swap: BADCCDAB
        if (data == 32'hBADCCDAB) begin
            $display("Test 3 PASS: swap symmetric = %08h", data);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %08h", data);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
