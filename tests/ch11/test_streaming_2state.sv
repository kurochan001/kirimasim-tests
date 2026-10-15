/*
:name: test_streaming_2state
:description: Streaming with 2-state types - pack
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_2state.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming with 2-state types - pack
module test_streaming_2state;
    bit [7:0] bytes [4];
    int packed_int;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack bit array to int
        bytes[0] = 8'hAA; bytes[1] = 8'hBB;
        bytes[2] = 8'hCC; bytes[3] = 8'hDD;
        packed_int = {>>{bytes}};
        if (packed_int == 32'hAABBCCDD) begin
            $display("Test 1 PASS: pack to int = %08h", packed_int);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", packed_int);
            fail_count++;
        end

        // Test 2: Pack sequential values
        bytes[0] = 8'h01; bytes[1] = 8'h02;
        bytes[2] = 8'h03; bytes[3] = 8'h04;
        packed_int = {>>{bytes}};
        if (packed_int == 32'h01020304) begin
            $display("Test 2 PASS: pack seq = %08h", packed_int);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", packed_int);
            fail_count++;
        end

        // Test 3: Pack all zeros
        bytes[0] = 8'h00; bytes[1] = 8'h00;
        bytes[2] = 8'h00; bytes[3] = 8'h00;
        packed_int = {>>{bytes}};
        if (packed_int == 32'h0) begin
            $display("Test 3 PASS: pack zeros = %08h", packed_int);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %08h", packed_int);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
