/*
:name: test_streaming_reverse
:description: Streaming byte swap
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_reverse.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming byte swap
module test_streaming_reverse;
    logic [15:0] word_val;
    logic [31:0] data;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Byte swap 16-bit
        word_val = 16'hABCD;
        word_val = {<<8{word_val}};  // Swap bytes
        if (word_val == 16'hCDAB) begin
            $display("Test 1 PASS: swap bytes = %04h", word_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %04h", word_val);
            fail_count++;
        end

        // Test 2: Byte swap 32-bit
        data = 32'h11223344;
        data = {<<8{data}};
        if (data == 32'h44332211) begin
            $display("Test 2 PASS: swap 32-bit = %08h", data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", data);
            fail_count++;
        end

        // Test 3: Double swap returns original
        data = 32'hDEADBEEF;
        data = {<<8{data}};
        data = {<<8{data}};
        if (data == 32'hDEADBEEF) begin
            $display("Test 3 PASS: double swap = %08h", data);
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
