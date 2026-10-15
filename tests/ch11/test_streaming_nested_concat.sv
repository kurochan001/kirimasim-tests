/*
:name: test_streaming_nested_concat
:description: Streaming concatenation with nested concat targets
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_nested_concat.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming concatenation with nested concat targets
module test_streaming_nested_concat;
    logic [7:0] a, b, c, d;
    logic [31:0] data;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic streaming with simple operands
        data = 32'hAABBCCDD;
        {>>{a, b, c, d}} = data;
        if (a === 8'hAA && b === 8'hBB && c === 8'hCC && d === 8'hDD) begin
            $display("PASS: Test 1 - Basic streaming {>>{a,b,c,d}} = 0xAABBCCDD");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Got a=%h b=%h c=%h d=%h", a, b, c, d);
            fail_count++;
        end

        // Test 2: Nested concatenation in streaming target
        data = 32'h11223344;
        {>>{{a, b}, {c, d}}} = data;
        if (a === 8'h11 && b === 8'h22 && c === 8'h33 && d === 8'h44) begin
            $display("PASS: Test 2 - Nested concat {>>{{a,b},{c,d}}} = 0x11223344");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Got a=%h b=%h c=%h d=%h", a, b, c, d);
            fail_count++;
        end

        // Test 3: Left-to-right streaming with different widths
        data = 32'hDEADBEEF;
        {>>{a, b}} = data[15:0];
        if (a === 8'hBE && b === 8'hEF) begin
            $display("PASS: Test 3 - {>>{a,b}} from 16-bit: BE EF");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Got a=%h b=%h", a, b);
            fail_count++;
        end

        // Summary
        $display("\n=== Streaming Nested Concat Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
