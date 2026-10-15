/*
:name: test_expr_streaming
:description: Test for streaming operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_streaming.expected
*/
// Test for streaming operators
// IEEE 1800-2023 §11.4.14: Streaming operators
module test_expr_streaming;
    int fails = 0;

    initial begin
        static logic [31:0] data = 32'h12345678;
        logic [31:0] result;
        logic [7:0] bytes[4];

        // {>>{}} streams left to right: the value is unchanged
        result = {>>{data}};
        if (result != 32'h12345678) begin fails++; $display("FAIL: left-to-right streaming"); end

        // {<<{}} streams right to left with 1-bit slices: the bits are reversed
        result = {<<{data}};
        if (result != 32'h1E6A2C48) begin fails++; $display("FAIL: bit reversal %h", result); end

        // Byte-level streaming
        result = {<<8{data}};
        if (result != 32'h78563412) begin fails++; $display("FAIL: Byte streaming %h", result); end

        // Unpack to array
        {>>{bytes}} = data;
        if (bytes[0] != 8'h12) begin fails++; $display("FAIL: Unpack [0] %h", bytes[0]); end
        if (bytes[3] != 8'h78) begin fails++; $display("FAIL: Unpack [3] %h", bytes[3]); end

        // Pack from array
        bytes[0] = 8'hAA;
        bytes[1] = 8'hBB;
        bytes[2] = 8'hCC;
        bytes[3] = 8'hDD;
        result = {>>{bytes}};
        if (result != 32'hAABBCCDD) begin fails++; $display("FAIL: Pack from array %h", result); end

        if (fails == 0) $display("PASS: Streaming operators");
        else $display("FAIL: %0d streaming checks failed", fails);
        $finish;
    end
endmodule
