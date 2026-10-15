/*
:name: test_streaming_queue
:description: Streaming with queues
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_queue.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming with queues
module test_streaming_queue;
    logic [7:0] q [$];
    logic [31:0] packed_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack queue to packed
        q = {8'hAA, 8'hBB, 8'hCC, 8'hDD};
        packed_val = {>>{q}};
        if (packed_val == 32'hAABBCCDD) begin
            $display("Test 1 PASS: pack queue = %08h", packed_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", packed_val);
            fail_count++;
        end

        // Test 2: Pack partial queue
        q = {8'h11, 8'h22};
        packed_val = 32'h0;
        packed_val[31:16] = {>>{q}};
        if (packed_val[31:16] == 16'h1122) begin
            $display("Test 2 PASS: partial pack = %08h", packed_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", packed_val);
            fail_count++;
        end

        // Test 3: Empty queue pack
        q = {};
        packed_val = 32'hDEADBEEF;
        packed_val = {>>{q}};
        // Empty queue should produce 0
        if (packed_val == 32'h0) begin
            $display("Test 3 PASS: empty queue = %08h", packed_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %08h", packed_val);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
