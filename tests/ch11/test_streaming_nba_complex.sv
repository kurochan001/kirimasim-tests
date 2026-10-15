/*
:name: test_streaming_nba_complex
:description: Streaming concatenation as the target of a nonblocking assignment
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.3 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_nba_complex.expected
*/
// IEEE 1800-2023 §10.4.2, §11.4.14: Streaming operator with NBA
module test_streaming_nba_complex;
    logic [7:0] a, b, c, d;
    logic [31:0] data;
    logic clk;
    int pass_count = 0;
    int fail_count = 0;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Test 1: Basic streaming NBA
        data = 32'hAABBCCDD;
        @(posedge clk);
        {>>{a, b, c, d}} <= data;
        @(posedge clk);
        if (a === 8'hAA && b === 8'hBB && c === 8'hCC && d === 8'hDD) begin
            $display("PASS: Test 1 - Streaming NBA {>>{a,b,c,d}} <= 0xAABBCCDD");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Got a=%h b=%h c=%h d=%h", a, b, c, d);
            fail_count++;
        end

        // Test 2: Streaming NBA with different data
        data = 32'h11223344;
        @(posedge clk);
        {>>{a, b, c, d}} <= data;
        @(posedge clk);
        if (a === 8'h11 && b === 8'h22 && c === 8'h33 && d === 8'h44) begin
            $display("PASS: Test 2 - Streaming NBA {>>{a,b,c,d}} <= 0x11223344");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Got a=%h b=%h c=%h d=%h", a, b, c, d);
            fail_count++;
        end

        // Summary
        $display("\n=== Streaming NBA Complex Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
