/*
:name: test_hamming_edge_cases
:description: Hamming(7,4) encoder and syndrome built from continuous assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 11.4.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hamming_edge_cases.expected
*/
// IEEE 1800-2023: Hamming code edge cases
// Tests for Hamming error detection/correction constructs

module test_hamming_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [3:0] data_in;
    logic [6:0] encoded;  // 4 data bits + 3 parity bits
    logic [3:0] data_out;
    logic [2:0] syndrome;
    logic error_detected;
    int bad7 = 0;

    // Hamming(7,4) encoder
    // P1 = D1 ^ D2 ^ D4
    // P2 = D1 ^ D3 ^ D4
    // P3 = D2 ^ D3 ^ D4
    assign encoded[0] = data_in[0] ^ data_in[1] ^ data_in[3];  // P1
    assign encoded[1] = data_in[0] ^ data_in[2] ^ data_in[3];  // P2
    assign encoded[2] = data_in[0];  // D1
    assign encoded[3] = data_in[1] ^ data_in[2] ^ data_in[3];  // P3
    assign encoded[4] = data_in[1];  // D2
    assign encoded[5] = data_in[2];  // D3
    assign encoded[6] = data_in[3];  // D4

    // Hamming decoder - calculate syndrome
    logic [6:0] received;
    assign received = encoded;  // In real test, could have errors

    assign syndrome[0] = received[0] ^ received[2] ^ received[4] ^ received[6];
    assign syndrome[1] = received[1] ^ received[2] ^ received[5] ^ received[6];
    assign syndrome[2] = received[3] ^ received[4] ^ received[5] ^ received[6];

    assign error_detected = |syndrome;
    assign data_out = {received[6], received[5], received[4], received[2]};

    initial begin
        // Test 1: Encode zero
        test_count++;
        data_in = 4'b0000;
        #1;
        if (encoded == 7'b0000000) begin
            pass_count++;
            $display("Test 1 PASS: 0000 encoded=%b", encoded);
        end else begin
            $display("Test 1 FAIL: unexpected encoded=%b", encoded);
        end

        // Test 2: No error syndrome
        test_count++;
        if (syndrome == 0 && error_detected == 0) begin
            pass_count++;
            $display("Test 2 PASS: No error syndrome=%b", syndrome);
        end else begin
            $display("Test 2 FAIL: unexpected syndrome=%b", syndrome);
        end

        // Test 3: Encode all ones
        test_count++;
        data_in = 4'b1111;
        #1;
        if (encoded == 7'b1111111) begin
            pass_count++;
            $display("Test 3 PASS: 1111 encoded=%b", encoded);
        end else begin
            $display("Test 3 FAIL: 1111 encoded=%b", encoded);
        end

        // Test 4: Decode back to original
        test_count++;
        if (data_out == data_in) begin
            pass_count++;
            $display("Test 4 PASS: Decoded=%b", data_out);
        end else begin
            $display("Test 4 FAIL: unexpected data_out=%b", data_out);
        end

        // Test 5: Encode 0101
        test_count++;
        data_in = 4'b0101;
        #1;
        if (encoded == 7'b0101101) begin
            pass_count++;
            $display("Test 5 PASS: 0101 encoded=%b", encoded);
        end else begin
            $display("Test 5 FAIL: 0101 encoded=%b", encoded);
        end

        // Test 6: Verify parity
        test_count++;
        if (syndrome == 0) begin
            pass_count++;
            $display("Test 6 PASS: Parity valid syndrome=%b", syndrome);
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: All data patterns
        test_count++;
        for (int i = 0; i < 16; i++) begin
            data_in = i[3:0];
            #1;
            if (syndrome != 0 || data_out != data_in) bad7++;
        end
        if (bad7 == 0) begin
            pass_count++;
            $display("Test 7 PASS: All patterns tested");
        end else begin
            $display("Test 7 FAIL: %0d patterns wrong", bad7);
        end

        $display("=== Hamming Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
