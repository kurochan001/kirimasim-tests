/*
:name: test_streaming_basic
:description: Streaming operators basic pack
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_basic.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming operators basic pack
module test_streaming_basic;
    logic [31:0] data;
    logic [7:0] bytes [4];
    logic [7:0] b1, b2, b3, b4;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack bytes array to 32-bit
        bytes[0] = 8'hAA; bytes[1] = 8'hBB; bytes[2] = 8'hCC; bytes[3] = 8'hDD;
        data = {>>{bytes}};
        if (data == 32'hAABBCCDD) begin
            $display("Test 1 PASS: pack array = %08h", data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", data);
            fail_count++;
        end

        // Test 2: Pack single element
        data = {>>{8'hFF}};
        // A stream narrower than the target is left-aligned and filled with
        // zeros on the right (11.4.14)
        if (data == 32'hFF000000) begin
            $display("Test 2 PASS: pack single = %08h", data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", data);
            fail_count++;
        end

        // Test 3: Pack variables
        b1 = 8'h11; b2 = 8'h22; b3 = 8'h33; b4 = 8'h44;
        data = {>>{b1, b2, b3, b4}};
        if (data == 32'h11223344) begin
            $display("Test 3 PASS: pack vars = %08h", data);
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
