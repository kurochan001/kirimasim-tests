/*
:name: test_shortreal_ieee754
:description: Real number system tasks and functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shortreal_ieee754.expected
*/
// IEEE 1800-2023 §20.5: Conversion functions
// Test $shortrealtobits and $bitstoshortreal for IEEE 754 compliance

module test_shortreal_conversion;
    initial begin
        shortreal x;
        bit [31:0] bits;
        shortreal y;

        $display("=== IEEE 1800-2023 §20.5: Shortreal Conversion Test ===\n");

        // Test 1: Positive value (1.5)
        $display("Test 1: 1.5 conversion");
        x = 1.5;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0x3fc00000)", bits);
        assert(bits == 32'h3fc00000) else $display("FAIL: 1.5 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == 1.5) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 2: Negative value (-2.5)
        $display("Test 2: -2.5 conversion");
        x = -2.5;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0xc0200000)", bits);
        assert(bits == 32'hc0200000) else $display("FAIL: -2.5 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == -2.5) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 3: Zero
        $display("Test 3: 0.0 conversion");
        x = 0.0;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0x00000000)", bits);
        assert(bits == 32'h00000000) else $display("FAIL: 0.0 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == 0.0) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 4: Small positive value (0.5)
        $display("Test 4: 0.5 conversion");
        x = 0.5;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0x3f000000)", bits);
        assert(bits == 32'h3f000000) else $display("FAIL: 0.5 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == 0.5) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 5: Negative one (-1.0)
        $display("Test 5: -1.0 conversion");
        x = -1.0;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0xbf800000)", bits);
        assert(bits == 32'hbf800000) else $display("FAIL: -1.0 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == -1.0) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 6: Positive one (1.0)
        $display("Test 6: 1.0 conversion");
        x = 1.0;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0x3f800000)", bits);
        assert(bits == 32'h3f800000) else $display("FAIL: 1.0 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == 1.0) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        // Test 7: Large value (100.0)
        $display("Test 7: 100.0 conversion");
        x = 100.0;
        bits = $shortrealtobits(x);
        $display("  Input: %f", x);
        $display("  Bits:  0x%h (expected 0x42c80000)", bits);
        assert(bits == 32'h42c80000) else $display("FAIL: 100.0 conversion incorrect, got 0x%h", bits);
        y = $bitstoshortreal(bits);
        $display("  Roundtrip: %f", y);
        assert(y == 100.0) else $display("FAIL: Roundtrip failed, got %f", y);
        $display("  PASS\n");

        $display("=== All Tests PASSED ===");
        $finish;
    end
endmodule
