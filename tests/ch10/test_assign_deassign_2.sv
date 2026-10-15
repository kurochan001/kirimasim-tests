/*
:name: test_assign_deassign_2
:description: Deassign statement
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_deassign_2.expected
*/
// Deassign statement
// Tests deassigning procedural continuous assignments

module test_assign_deassign;
    reg [7:0] sig_a;
    reg [7:0] sig_b;
    reg [7:0] source;

    reg [15:0] wide_sig;
    reg [3:0] narrow_sig;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        sig_a = 8'h00;
        sig_b = 8'h00;
        source = 8'hAB;
        wide_sig = 16'h0000;
        narrow_sig = 4'h0;
        #1;

        // Test 1: Assign then deassign
        assign sig_a = source;
        #1;
        if (sig_a == 8'hAB) begin
            $display("PASS: Test 1a - Procedural assign active");
            pass_count++;
        end else begin
            $display("FAIL: Test 1a - expected 0xAB, got 0x%0h", sig_a);
            fail_count++;
        end

        deassign sig_a;
        #1;
        // Value should be retained after deassign
        if (sig_a == 8'hAB) begin
            $display("PASS: Test 1b - Value retained after deassign");
            pass_count++;
        end else begin
            $display("FAIL: Test 1b - expected 0xAB (retained), got 0x%0h", sig_a);
            fail_count++;
        end

        // Test 2: Source change after deassign doesn't affect target
        source = 8'hCD;
        #1;
        if (sig_a == 8'hAB) begin
            $display("PASS: Test 2 - Source change after deassign doesn't propagate");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0xAB (no propagation), got 0x%0h", sig_a);
            fail_count++;
        end

        // Test 3: Regular assignment works after deassign
        sig_a = 8'h99;
        #1;
        if (sig_a == 8'h99) begin
            $display("PASS: Test 3 - Regular assignment works after deassign");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0x99, got 0x%0h", sig_a);
            fail_count++;
        end

        // Test 4: Multiple assign-deassign cycles
        assign sig_b = source;
        #1;
        deassign sig_b;
        assign sig_b = 8'h11;
        #1;
        if (sig_b == 8'h11) begin
            $display("PASS: Test 4a - Second assign after deassign");
            pass_count++;
        end else begin
            $display("FAIL: Test 4a - expected 0x11, got 0x%0h", sig_b);
            fail_count++;
        end

        deassign sig_b;
        sig_b = 8'h22;
        #1;
        if (sig_b == 8'h22) begin
            $display("PASS: Test 4b - Procedural write after second deassign");
            pass_count++;
        end else begin
            $display("FAIL: Test 4b - expected 0x22, got 0x%0h", sig_b);
            fail_count++;
        end

        // Test 5: Deassign on non-assigned signal (should be no-op)
        narrow_sig = 4'hA;
        deassign narrow_sig;
        #1;
        narrow_sig = 4'hB;
        #1;
        if (narrow_sig == 4'hB) begin
            $display("PASS: Test 5 - Deassign on non-assigned signal is no-op");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 0xB, got 0x%0h", narrow_sig);
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All deassign tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
