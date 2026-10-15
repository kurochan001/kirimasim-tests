/*
:name: test_system_shortrealtobits
:description: Test $shortrealtobits - shortreal to bit pattern conversion
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_shortrealtobits.expected
*/
// Test $shortrealtobits - shortreal to bit pattern conversion
module test_shortrealtobits;
    shortreal sr1, sr2, sr3, sr4, sr5;
    bit [31:0] bits1, bits2, bits3, bits4, bits5;

    initial begin
        // Test 1: Positive shortreal (1.0 = 0x3F800000)
        sr1 = 1.0;
        bits1 = $shortrealtobits(sr1);
        if (bits1 == 32'h3F800000)
            $display("PASS: $shortrealtobits(1.0) = 0x%08X", bits1);
        else
            $display("FAIL: $shortrealtobits(1.0) = 0x%08X, expected 0x3F800000", bits1);

        // Test 2: Negative shortreal (-1.0 = 0xBF800000)
        sr2 = -1.0;
        bits2 = $shortrealtobits(sr2);
        if (bits2 == 32'hBF800000)
            $display("PASS: $shortrealtobits(-1.0) = 0x%08X", bits2);
        else
            $display("FAIL: $shortrealtobits(-1.0) = 0x%08X, expected 0xBF800000", bits2);

        // Test 3: Zero (0.0 = 0x00000000)
        sr3 = 0.0;
        bits3 = $shortrealtobits(sr3);
        if (bits3 == 32'h00000000)
            $display("PASS: $shortrealtobits(0.0) = 0x%08X", bits3);
        else
            $display("FAIL: $shortrealtobits(0.0) = 0x%08X, expected 0x00000000", bits3);

        // Test 4: Two (2.0 = 0x40000000)
        sr4 = 2.0;
        bits4 = $shortrealtobits(sr4);
        if (bits4 == 32'h40000000)
            $display("PASS: $shortrealtobits(2.0) = 0x%08X", bits4);
        else
            $display("FAIL: $shortrealtobits(2.0) = 0x%08X, expected 0x40000000", bits4);

        // Test 5: Half (0.5 = 0x3F000000)
        sr5 = 0.5;
        bits5 = $shortrealtobits(sr5);
        if (bits5 == 32'h3F000000)
            $display("PASS: $shortrealtobits(0.5) = 0x%08X", bits5);
        else
            $display("FAIL: $shortrealtobits(0.5) = 0x%08X, expected 0x3F000000", bits5);

        $finish;
    end
endmodule
