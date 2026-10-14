/*
:name: test_strength_resolution
:description: Corner Case: Signal Strength Resolution
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.4 28.10 28.11 28.12
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_strength_resolution.expected
*/
// Corner Case: Signal Strength Resolution
// Tests strength resolution between drivers

module test_strength_resolution;
    int pass_count = 0;
    int fail_count = 0;

    // Control signals
    logic enable_supply, enable_strong, enable_pull, enable_weak;
    logic val_supply, val_strong, val_pull, val_weak;

    // Test wires with different strength drivers
    wire test_wire;
    wire multi_driver;

    // Supply strength (strongest)
    assign (supply0, supply1) test_wire = enable_supply ? val_supply : 1'bz;

    // Strong strength
    assign (strong0, strong1) test_wire = enable_strong ? val_strong : 1'bz;

    // Pull strength
    assign (pull0, pull1) test_wire = enable_pull ? val_pull : 1'bz;

    // Weak strength (weakest)
    assign (weak0, weak1) test_wire = enable_weak ? val_weak : 1'bz;

    // Multiple drivers for resolution testing
    assign (strong0, strong1) multi_driver = enable_strong ? 1'b1 : 1'bz;
    assign (weak0, weak1) multi_driver = enable_weak ? 1'b0 : 1'bz;

    // Pullup and pulldown
    wire pulled_up;
    wire pulled_down;

    pullup (pulled_up);
    pulldown (pulled_down);

    wire driven_pullup;
    wire driven_pulldown;

    pullup (driven_pullup);
    pulldown (driven_pulldown);

    assign (strong0, strong1) driven_pullup = enable_strong ? val_strong : 1'bz;
    assign (strong0, strong1) driven_pulldown = enable_strong ? val_strong : 1'bz;

    initial begin
        // Initialize all disabled
        enable_supply = 0;
        enable_strong = 0;
        enable_pull = 0;
        enable_weak = 0;
        val_supply = 0;
        val_strong = 0;
        val_pull = 0;
        val_weak = 0;

        #1;

        // Test 1: No driver (high-Z)
        if (test_wire === 1'bz) pass_count++;
        else begin fail_count++; $display("FAIL: no driver, got %b", test_wire); end

        // Test 2: Weak driver only
        enable_weak = 1;
        val_weak = 1;
        #1;
        if (test_wire === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: weak only, got %b", test_wire); end

        // Test 3: Pull overrides weak
        enable_pull = 1;
        val_pull = 0;  // Pull drives 0, weak drives 1
        #1;
        if (test_wire === 1'b0) pass_count++;
        else begin fail_count++; $display("FAIL: pull > weak, got %b", test_wire); end

        // Test 4: Strong overrides pull
        enable_strong = 1;
        val_strong = 1;  // Strong drives 1
        #1;
        if (test_wire === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: strong > pull, got %b", test_wire); end

        // Test 5: Supply overrides strong
        enable_supply = 1;
        val_supply = 0;  // Supply drives 0
        #1;
        if (test_wire === 1'b0) pass_count++;
        else begin fail_count++; $display("FAIL: supply > strong, got %b", test_wire); end

        // Reset all
        enable_supply = 0;
        enable_strong = 0;
        enable_pull = 0;
        enable_weak = 0;
        #1;

        // Test 6: Strong vs weak resolution
        enable_strong = 1;
        val_strong = 1;
        enable_weak = 1;
        val_weak = 0;  // Different value
        #1;
        if (multi_driver === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: strong vs weak, got %b", multi_driver); end

        // Test 7: Pullup default
        if (pulled_up === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: pullup default, got %b", pulled_up); end

        // Test 8: Pulldown default
        if (pulled_down === 1'b0) pass_count++;
        else begin fail_count++; $display("FAIL: pulldown default, got %b", pulled_down); end

        // Test 9: Strong overrides pullup
        enable_strong = 1;
        val_strong = 0;  // Drive low against pullup
        #1;
        if (driven_pullup === 1'b0) pass_count++;
        else begin fail_count++; $display("FAIL: strong > pullup, got %b", driven_pullup); end

        // Test 10: Strong overrides pulldown
        val_strong = 1;  // Drive high against pulldown
        #1;
        if (driven_pulldown === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: strong > pulldown, got %b", driven_pulldown); end

        // Test 11: Release to pullup
        enable_strong = 0;
        #1;
        if (driven_pullup === 1'b1) pass_count++;
        else begin fail_count++; $display("FAIL: release to pullup, got %b", driven_pullup); end

        // Test 12: Release to pulldown
        if (driven_pulldown === 1'b0) pass_count++;
        else begin fail_count++; $display("FAIL: release to pulldown, got %b", driven_pulldown); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/12)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
