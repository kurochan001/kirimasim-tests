/*
:name: test_system_bitstoshortreal
:description: Test $bitstoshortreal - bit pattern to shortreal conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_bitstoshortreal.expected
*/
// Test $bitstoshortreal - bit pattern to shortreal conversion
module test_bitstoshortreal;
    bit [31:0] bits1, bits2, bits3, bits4, bits5;
    shortreal sr1, sr2, sr3, sr4, sr5;

    initial begin
        // Test 1: 1.0 from bits (0x3F800000)
        bits1 = 32'h3F800000;
        sr1 = $bitstoshortreal(bits1);
        if (sr1 == 1.0)
            $display("PASS: $bitstoshortreal(0x3F800000) = %f", sr1);
        else
            $display("FAIL: $bitstoshortreal(0x3F800000) = %f, expected 1.0", sr1);

        // Test 2: -1.0 from bits (0xBF800000)
        bits2 = 32'hBF800000;
        sr2 = $bitstoshortreal(bits2);
        if (sr2 == -1.0)
            $display("PASS: $bitstoshortreal(0xBF800000) = %f", sr2);
        else
            $display("FAIL: $bitstoshortreal(0xBF800000) = %f, expected -1.0", sr2);

        // Test 3: 0.0 from bits (0x00000000)
        bits3 = 32'h00000000;
        sr3 = $bitstoshortreal(bits3);
        if (sr3 == 0.0)
            $display("PASS: $bitstoshortreal(0x00000000) = %f", sr3);
        else
            $display("FAIL: $bitstoshortreal(0x00000000) = %f, expected 0.0", sr3);

        // Test 4: 2.0 from bits (0x40000000)
        bits4 = 32'h40000000;
        sr4 = $bitstoshortreal(bits4);
        if (sr4 == 2.0)
            $display("PASS: $bitstoshortreal(0x40000000) = %f", sr4);
        else
            $display("FAIL: $bitstoshortreal(0x40000000) = %f, expected 2.0", sr4);

        // Test 5: 0.5 from bits (0x3F000000)
        bits5 = 32'h3F000000;
        sr5 = $bitstoshortreal(bits5);
        if (sr5 == 0.5)
            $display("PASS: $bitstoshortreal(0x3F000000) = %f", sr5);
        else
            $display("FAIL: $bitstoshortreal(0x3F000000) = %f, expected 0.5", sr5);

        $finish;
    end
endmodule
