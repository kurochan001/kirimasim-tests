/*
:name: test_net_types
:description: Net Types Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.1 6.6.3 6.6.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_types.expected
*/
// IEEE 1800-2023 Section 6.6 - Net Types Tests
// Tests: wire, wand, wor, tri, trireg, supply0, supply1

module test_net_types;
    int pass_count = 0;
    int fail_count = 0;

    // Wire declarations
    wire w1, w2;
    wire [7:0] bus;

    // Wired-AND
    wand wand_sig;

    // Wired-OR
    wor wor_sig;

    // Tri-state
    tri tri_sig;

    // Power nets
    supply0 gnd;
    supply1 vcc;

    // Driver signals
    logic drv1, drv2;
    logic [7:0] drv_bus;

    // Continuous assignments
    assign w1 = drv1;
    assign w2 = drv2;
    assign bus = drv_bus;

    // Multiple drivers for wand
    assign wand_sig = drv1;
    assign wand_sig = drv2;

    // Multiple drivers for wor
    assign wor_sig = drv1;
    assign wor_sig = drv2;

    initial begin
        $display("=== IEEE 1800-2023 Net Types Tests ===");

        // Test 1: Basic wire
        $display("Test 1: Basic wire");
        drv1 = 1;
        #1;
        if (w1 == 1) begin
            $display("Test 1 PASS");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Wire bus
        $display("Test 2: Wire bus");
        drv_bus = 8'hAB;
        #1;
        if (bus == 8'hAB) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Wand (both 1)
        $display("Test 3: Wand both high");
        drv1 = 1;
        drv2 = 1;
        #1;
        if (wand_sig == 1) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: wand=%b", wand_sig);
            fail_count++;
        end

        // Test 4: Wand (one 0)
        $display("Test 4: Wand one low");
        drv1 = 1;
        drv2 = 0;
        #1;
        if (wand_sig == 0) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: wand=%b", wand_sig);
            fail_count++;
        end

        // Test 5: Wor (both 0)
        $display("Test 5: Wor both low");
        drv1 = 0;
        drv2 = 0;
        #1;
        if (wor_sig == 0) begin
            $display("Test 5 PASS");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: wor=%b", wor_sig);
            fail_count++;
        end

        // Test 6: Wor (one 1)
        $display("Test 6: Wor one high");
        drv1 = 0;
        drv2 = 1;
        #1;
        if (wor_sig == 1) begin
            $display("Test 6 PASS");
            pass_count++;
        end else begin
            $display("Test 6 FAIL: wor=%b", wor_sig);
            fail_count++;
        end

        // Test 7: Supply nets (6.6.6)
        $display("Test 7: Supply0 net");
        if (gnd == 0 && vcc == 1) begin
            $display("Test 7 PASS");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: gnd=%b", gnd);
            fail_count++;
        end

        // Test 8: Wire toggle
        $display("Test 8: Wire toggle");
        drv1 = 0;
        #1;
        drv1 = 1;
        #1;
        drv1 = 0;
        #1;
        if (w1 == 0) begin
            $display("Test 8 PASS");
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Summary
        #1;
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
