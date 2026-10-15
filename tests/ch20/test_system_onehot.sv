/*
:name: test_system_onehot
:description: $onehot - exactly one bit set check
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_onehot.expected
*/
// $onehot - exactly one bit set check
module test_onehot;
    logic [7:0] val8;
    logic [15:0] val16;
    int result;

    initial begin
        // Test 1: Exactly one bit set (LSB)
        val8 = 8'b00000001;
        result = $onehot(val8);
        if (result == 1)
            $display("PASS: $onehot(8'b00000001) = %0d (one-hot)", result);
        else
            $display("FAIL: $onehot(8'b00000001) = %0d, expected 1", result);

        // Test 2: Exactly one bit set (MSB)
        val8 = 8'b10000000;
        result = $onehot(val8);
        if (result == 1)
            $display("PASS: $onehot(8'b10000000) = %0d (one-hot)", result);
        else
            $display("FAIL: $onehot(8'b10000000) = %0d, expected 1", result);

        // Test 3: Two bits set (not one-hot)
        val8 = 8'b00000011;
        result = $onehot(val8);
        if (result == 0)
            $display("PASS: $onehot(8'b00000011) = %0d (not one-hot)", result);
        else
            $display("FAIL: $onehot(8'b00000011) = %0d, expected 0", result);

        // Test 4: No bits set (not one-hot)
        val8 = 8'b00000000;
        result = $onehot(val8);
        if (result == 0)
            $display("PASS: $onehot(8'b00000000) = %0d (not one-hot)", result);
        else
            $display("FAIL: $onehot(8'b00000000) = %0d, expected 0", result);

        // Test 5: 16-bit one-hot
        val16 = 16'h0100;
        result = $onehot(val16);
        if (result == 1)
            $display("PASS: $onehot(16'h0100) = %0d (one-hot)", result);
        else
            $display("FAIL: $onehot(16'h0100) = %0d, expected 1", result);

        $finish;
    end
endmodule
