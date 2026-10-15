/*
:name: test_system_countones
:description: $countones - count number of 1 bits
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_countones.expected
*/
// $countones - count number of 1 bits
module test_countones;
    logic [7:0] val8;
    logic [15:0] val16;
    logic [31:0] val32;
    int count;

    initial begin
        // Test 1: All zeros
        val8 = 8'b00000000;
        count = $countones(val8);
        if (count == 0)
            $display("PASS: $countones(8'b00000000) = %0d", count);
        else
            $display("FAIL: $countones(8'b00000000) = %0d, expected 0", count);

        // Test 2: All ones (8-bit)
        val8 = 8'b11111111;
        count = $countones(val8);
        if (count == 8)
            $display("PASS: $countones(8'b11111111) = %0d", count);
        else
            $display("FAIL: $countones(8'b11111111) = %0d, expected 8", count);

        // Test 3: Alternating bits
        val8 = 8'b10101010;
        count = $countones(val8);
        if (count == 4)
            $display("PASS: $countones(8'b10101010) = %0d", count);
        else
            $display("FAIL: $countones(8'b10101010) = %0d, expected 4", count);

        // Test 4: Single bit set (16-bit)
        val16 = 16'h0100;
        count = $countones(val16);
        if (count == 1)
            $display("PASS: $countones(16'h0100) = %0d", count);
        else
            $display("FAIL: $countones(16'h0100) = %0d, expected 1", count);

        // Test 5: Multiple bits (32-bit)
        val32 = 32'hF0F0F0F0;  // 16 ones
        count = $countones(val32);
        if (count == 16)
            $display("PASS: $countones(32'hF0F0F0F0) = %0d", count);
        else
            $display("FAIL: $countones(32'hF0F0F0F0) = %0d, expected 16", count);

        $finish;
    end
endmodule
