/*
:name: test_system_onehot0
:description: $onehot0 - at most one bit set check (zero or one bit)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_onehot0.expected
*/
// $onehot0 - at most one bit set check (zero or one bit)
module test_onehot0;
    logic [7:0] val8;
    logic [15:0] val16;
    int result;

    initial begin
        // Test 1: Exactly one bit set
        val8 = 8'b00000001;
        result = $onehot0(val8);
        if (result == 1)
            $display("PASS: $onehot0(8'b00000001) = %0d (valid)", result);
        else
            $display("FAIL: $onehot0(8'b00000001) = %0d, expected 1", result);

        // Test 2: No bits set (valid for onehot0)
        val8 = 8'b00000000;
        result = $onehot0(val8);
        if (result == 1)
            $display("PASS: $onehot0(8'b00000000) = %0d (valid - zero)", result);
        else
            $display("FAIL: $onehot0(8'b00000000) = %0d, expected 1", result);

        // Test 3: Two bits set (invalid)
        val8 = 8'b00000011;
        result = $onehot0(val8);
        if (result == 0)
            $display("PASS: $onehot0(8'b00000011) = %0d (invalid)", result);
        else
            $display("FAIL: $onehot0(8'b00000011) = %0d, expected 0", result);

        // Test 4: MSB set only
        val8 = 8'b10000000;
        result = $onehot0(val8);
        if (result == 1)
            $display("PASS: $onehot0(8'b10000000) = %0d (valid)", result);
        else
            $display("FAIL: $onehot0(8'b10000000) = %0d, expected 1", result);

        // Test 5: All bits set (invalid)
        val16 = 16'hFFFF;
        result = $onehot0(val16);
        if (result == 0)
            $display("PASS: $onehot0(16'hFFFF) = %0d (invalid)", result);
        else
            $display("FAIL: $onehot0(16'hFFFF) = %0d, expected 0", result);

        $finish;
    end
endmodule
