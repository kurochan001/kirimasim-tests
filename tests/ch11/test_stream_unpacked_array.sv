/*
:name: test_stream_unpacked_array
:description: Test for array casts
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 7.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_unpacked_array.expected
*/
// Test for array casts
// IEEE 1800-2023 §11.4.14: an unpacked array streamed to and from a packed value
module test_stream_unpacked_array;
    int fails = 0;

    initial begin
        logic [7:0] arr1[4];
        logic [31:0] packed_val;
        logic [7:0] arr2[4];

        // Initialize array
        arr1 = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};

        // Array to packed (streaming)
        packed_val = {>>{arr1}};
        if (packed_val != 32'hAABBCCDD) begin fails++; $display("FAIL: array to packed"); end

        // Packed to array (streaming)
        packed_val = 32'h11223344;
        {>>{arr2}} = packed_val;
        if (arr2[0] != 8'h11) begin fails++; $display("FAIL: packed to array [0]"); end
        if (arr2[3] != 8'h44) begin fails++; $display("FAIL: packed to array [3]"); end

        if (fails == 0) $display("PASS: Array casts");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
