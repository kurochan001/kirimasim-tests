/*
:name: test_streaming_wide
:description: Streaming with wide vectors - pack
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_wide.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming with wide vectors - pack
module test_streaming_wide;
    logic [63:0] wide64;
    logic [7:0] bytes [8];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack 8 bytes to 64-bit
        bytes[0] = 8'h00; bytes[1] = 8'h11; bytes[2] = 8'h22; bytes[3] = 8'h33;
        bytes[4] = 8'h44; bytes[5] = 8'h55; bytes[6] = 8'h66; bytes[7] = 8'h77;
        wide64 = {>>{bytes}};
        if (wide64 == 64'h0011223344556677) begin
            $display("Test 1 PASS: pack 8 bytes = %016h", wide64);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %016h", wide64);
            fail_count++;
        end

        // Test 2: Pack all FF
        bytes[0] = 8'hFF; bytes[1] = 8'hFF; bytes[2] = 8'hFF; bytes[3] = 8'hFF;
        bytes[4] = 8'hFF; bytes[5] = 8'hFF; bytes[6] = 8'hFF; bytes[7] = 8'hFF;
        wide64 = {>>{bytes}};
        if (wide64 == 64'hFFFFFFFFFFFFFFFF) begin
            $display("Test 2 PASS: pack FF = %016h", wide64);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %016h", wide64);
            fail_count++;
        end

        // Test 3: Pack all 00
        bytes[0] = 8'h00; bytes[1] = 8'h00; bytes[2] = 8'h00; bytes[3] = 8'h00;
        bytes[4] = 8'h00; bytes[5] = 8'h00; bytes[6] = 8'h00; bytes[7] = 8'h00;
        wide64 = {>>{bytes}};
        if (wide64 == 64'h0) begin
            $display("Test 3 PASS: pack zeros = %016h", wide64);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %016h", wide64);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
