/*
:name: test_real_bits_simple
:description: $realtobits, $bitstoreal, $shortrealtobits and $bitstoshortreal
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_bits_simple.expected
*/
// $realtobits, $bitstoreal, $shortrealtobits and $bitstoshortreal
module test_real_bits_simple;
    real r1, r2;
    real sr;  // $shortrealtobits converts this real value to shortreal (20.5)
    reg [63:0] bits64;
    reg [31:0] bits32;

    initial begin
        $display("=== Real/Bits Conversion Test ===");

        // Test $realtobits and $bitstoreal
        r1 = 3.14159;
        bits64 = $realtobits(r1);
        $display("$realtobits(3.14159) = %h", bits64);

        r2 = $bitstoreal(bits64);
        $display("$bitstoreal(%h) = %f", bits64, r2);
        if (r2 == r1) begin
            $display("PASS: $realtobits/$bitstoreal");
        end else begin
            $display("FAIL: Expected %f, got %f", r1, r2);
        end

        // Test $shortrealtobits and $bitstoshortreal with real
        sr = 2.71828;
        bits32 = $shortrealtobits(sr);
        $display("\n$shortrealtobits(2.71828) = %h", bits32);

        r2 = $bitstoshortreal(bits32);
        $display("$bitstoshortreal(%h) = %f", bits32, r2);

        // Check if value is approximately correct (allowing for float precision)
        if (r2 > 2.718 && r2 < 2.719) begin
            $display("PASS: $shortrealtobits/$bitstoshortreal");
        end else begin
            $display("FAIL: Expected ~2.71828, got %f", r2);
        end

        // Test special values
        $display("\n--- Special Values ---");

        // Zero
        r1 = 0.0;
        bits64 = $realtobits(r1);
        $display("$realtobits(0.0) = %h", bits64);

        // Negative
        r1 = -1.0;
        bits64 = $realtobits(r1);
        $display("$realtobits(-1.0) = %h", bits64);

        // Large value
        r1 = 1234567890.0;
        bits64 = $realtobits(r1);
        r2 = $bitstoreal(bits64);
        $display("Round-trip 1234567890.0: %f", r2);

        $display("\n=== Test Complete ===");
        $finish;
    end
endmodule
