/*
:name: test_nba_complex_lhs
:description: Non-blocking assignment with complex LHS
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_complex_lhs.expected
*/
// IEEE 1800-2023 §10.4.2: Non-blocking assignment with complex LHS
// Tests various NBA LHS patterns:
// 1. Simple bit select: sig[0] <= value
// 2. Simple part select: sig[7:0] <= value
// 3. Member access: obj.member <= value
// 4. Complex LHS: obj.sig[0] <= value (member + bit select)
// 5. Multiple NBA to same signal

module test_nba_complex_lhs;
    // Test structure
    typedef struct packed {
        logic [7:0] data;
        logic [3:0] control;
    } packet_t;

    // Test signals
    logic [15:0] simple_sig;
    packet_t pkt;
    logic clk = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Test results
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        simple_sig = 16'h0000;
        pkt.data = 8'h00;
        pkt.control = 4'h0;

        // Wait for clock edge
        @(posedge clk);

        // Test 1: Simple bit select NBA
        simple_sig[0] <= 1'b1;
        simple_sig[15] <= 1'b1;
        @(posedge clk);

        if (simple_sig == 16'h8001) begin
            $display("PASS: Test 1 - Simple bit select NBA");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x8001, got 0x%04x", simple_sig);
            fail_count++;
        end

        // Test 2: Simple part select NBA
        simple_sig <= 16'h0000;
        @(posedge clk);
        simple_sig[7:0] <= 8'hAB;
        simple_sig[15:8] <= 8'hCD;
        @(posedge clk);

        if (simple_sig == 16'hCDAB) begin
            $display("PASS: Test 2 - Simple part select NBA");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0xCDAB, got 0x%04x", simple_sig);
            fail_count++;
        end

        // Test 3: Member access NBA
        pkt.data <= 8'hFF;
        pkt.control <= 4'hA;
        @(posedge clk);

        if (pkt.data == 8'hFF && pkt.control == 4'hA) begin
            $display("PASS: Test 3 - Member access NBA");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected data=0xFF control=0xA, got data=0x%02x control=0x%01x",
                     pkt.data, pkt.control);
            fail_count++;
        end

        // Test 4: Complex LHS - member + bit select
        pkt.data <= 8'h00;
        @(posedge clk);
        pkt.data[0] <= 1'b1;  // Complex LHS: struct.member[bit]
        pkt.data[7] <= 1'b1;
        @(posedge clk);

        if (pkt.data == 8'h81) begin
            $display("PASS: Test 4 - Complex LHS (member + bit select) NBA");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0x81, got 0x%02x", pkt.data);
            fail_count++;
        end

        // Test 5: Multiple NBA to same signal (overlapping ranges)
        simple_sig <= 16'h0000;
        @(posedge clk);
        simple_sig[3:0] <= 4'hF;
        simple_sig[7:4] <= 4'hE;
        simple_sig[11:8] <= 4'hD;
        simple_sig[15:12] <= 4'hC;
        @(posedge clk);

        if (simple_sig == 16'hCDEF) begin
            $display("PASS: Test 5 - Multiple NBA to same signal");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xCDEF, got 0x%04x", simple_sig);
            fail_count++;
        end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
