/*
:name: test_streaming_dynamic
:description: Streaming with dynamic arrays - pack only
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_dynamic.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming with dynamic arrays - pack only
module test_streaming_dynamic;
    logic [7:0] dyn_arr [];
    logic [31:0] packed_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Pack 4-element dynamic array
        dyn_arr = new[4];
        dyn_arr[0] = 8'h11; dyn_arr[1] = 8'h22;
        dyn_arr[2] = 8'h33; dyn_arr[3] = 8'h44;
        packed_val = {>>{dyn_arr}};
        if (packed_val == 32'h11223344) begin
            $display("Test 1 PASS: pack 4 elements = %08h", packed_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", packed_val);
            fail_count++;
        end

        // Test 2: Pack with hex values
        dyn_arr[0] = 8'hAA; dyn_arr[1] = 8'hBB;
        dyn_arr[2] = 8'hCC; dyn_arr[3] = 8'hDD;
        packed_val = {>>{dyn_arr}};
        if (packed_val == 32'hAABBCCDD) begin
            $display("Test 2 PASS: pack hex = %08h", packed_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %08h", packed_val);
            fail_count++;
        end

        // Test 3: Pack all ones
        dyn_arr[0] = 8'hFF; dyn_arr[1] = 8'hFF;
        dyn_arr[2] = 8'hFF; dyn_arr[3] = 8'hFF;
        packed_val = {>>{dyn_arr}};
        if (packed_val == 32'hFFFFFFFF) begin
            $display("Test 3 PASS: pack ones = %08h", packed_val);
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
