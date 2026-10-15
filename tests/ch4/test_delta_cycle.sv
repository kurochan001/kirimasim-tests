/*
:name: test_delta_cycle
:description: Test for Delta Cycle precision
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 4.6 10.4.2 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delta_cycle.expected
*/
// Test for Delta Cycle precision
// IEEE 1800-2023 Section 4.3 - Stratified event queue

module test_delta_cycle;
    reg [7:0] a, b, c;
    wire [7:0] w1, w2;

    // Continuous assignments create delta delays
    assign w1 = a + 1;
    assign w2 = w1 + 1;

    initial begin
        $display("=== Delta Cycle Test ===");

        // Initial values
        a = 8'h00;
        b = 8'h00;
        c = 8'h00;

        // Test #0 delay (inactive region)
        #0 $display("Time %0t: After #0 delay", $time);

        // Test blocking and non-blocking mix
        a = 8'h10;  // Blocking - immediate
        b <= a;     // Non-blocking - NBA region
        c <= b;     // Non-blocking - NBA region

        #0;  // Allow delta cycles to complete

        $display("After delta cycles:");
        $display("  a=%02X (should be 10)", a);
        $display("  b=%02X (should be 00)", b);
        $display("  c=%02X (should be 00)", c);
        $display("  w1=%02X (should be 11)", w1);
        $display("  w2=%02X (should be 12)", w2);

        // Move to next time slot
        #1;

        $display("After #1:");
        $display("  a=%02X (should be 10)", a);
        $display("  b=%02X (should be 10)", b);
        $display("  c=%02X (should be 00)", c);

        // Verify results
        if (a == 8'h10 && b == 8'h10 && c == 8'h00 && w1 == 8'h11 && w2 == 8'h12) begin
            $display("PASS: Delta cycles working correctly");
        end else begin
            $display("FAIL: Delta cycle issues detected");
        end

        $finish;
    end
endmodule
