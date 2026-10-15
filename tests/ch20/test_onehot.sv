/*
:name: test_onehot
:description: One-hot functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_onehot.expected
*/
// IEEE 1800-2023 Section 20.9: One-hot functions
module test_onehot;
    logic [7:0] val;
    int result;

    initial begin
        // $onehot
        val = 8'b0001_0000;
        result = $onehot(val);
        if (result == 1)
            $display("PASS: $onehot single bit");
        else
            $display("FAIL: onehot1 = %0d", result);

        val = 8'b0001_0001;  // Two bits set
        result = $onehot(val);
        if (result == 0)
            $display("PASS: $onehot two bits");
        else
            $display("FAIL: onehot2 = %0d", result);

        val = 8'b0000_0000;  // No bits
        result = $onehot(val);
        if (result == 0)
            $display("PASS: $onehot zero");
        else
            $display("FAIL: onehot0 = %0d", result);

        // $onehot0 (zero or one-hot)
        val = 8'b0000_0000;
        result = $onehot0(val);
        if (result == 1)
            $display("PASS: $onehot0 zero");
        else
            $display("FAIL: onehot0z = %0d", result);

        val = 8'b0000_0001;
        result = $onehot0(val);
        if (result == 1)
            $display("PASS: $onehot0 single");
        else
            $display("FAIL: onehot0s = %0d", result);

        $display("TEST PASSED: onehot tests completed");
        $finish;
    end
endmodule
