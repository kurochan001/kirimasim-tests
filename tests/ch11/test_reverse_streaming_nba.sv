/*
:name: test_reverse_streaming_nba
:description: Reverse streaming operator on LHS of NBA
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.3 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reverse_streaming_nba.expected
*/
// IEEE 1800-2023 §11.4.14: Reverse streaming operator on LHS of NBA
// Tests {<<byte{result}} <= value and {<<1{result}} <= value
// The << operator reverses slice order before assignment
module test_reverse_streaming_nba;
    logic [31:0] result;
    logic clk = 0;
    int pass_count = 0;
    int fail_count = 0;

    always #5 clk = ~clk;

    initial begin
        // Test 1: Reverse streaming NBA - byte reversal
        // {<<byte{result}} <= 32'hAABBCCDD -> bytes reversed -> DDCCBBAA
        @(posedge clk);
        {<<byte{result}} <= 32'hAABBCCDD;
        @(posedge clk);
        if (result === 32'hDDCCBBAA) begin
            $display("PASS: Test 1 - reverse streaming NBA byte: result=%h", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - reverse streaming NBA byte: result=%h (expected DDCCBBAA)", result);
            fail_count++;
        end

        // Test 2: Reverse streaming NBA with bit granularity
        // {<<1{result}} <= 32'hF0F0F0F0 -> bit-reversed -> 0F0F0F0F
        @(posedge clk);
        {<<1{result}} <= 32'hF0F0F0F0;
        @(posedge clk);
        if (result === 32'h0F0F0F0F) begin
            $display("PASS: Test 2 - reverse streaming NBA bit: result=%h", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - reverse streaming NBA bit: result=%h (expected 0F0F0F0F)", result);
            fail_count++;
        end

        // Test 3: Forward streaming NBA for comparison (>> preserves order)
        @(posedge clk);
        {>>byte{result}} <= 32'hAABBCCDD;
        @(posedge clk);
        if (result === 32'hAABBCCDD) begin
            $display("PASS: Test 3 - forward streaming NBA byte: result=%h", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - forward streaming NBA byte: result=%h (expected AABBCCDD)", result);
            fail_count++;
        end

        $display("\n=== Reverse Streaming NBA Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
