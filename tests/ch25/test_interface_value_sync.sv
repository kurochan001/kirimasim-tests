/*
:name: test_interface_value_sync
:description: Values through an interface port and interface variables
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_value_sync.expected
*/
// IEEE 1800-2023 Interface Signal Value Synchronization Test
// Tests that signal values propagate through interface port connections

interface data_bus(input logic clk);
    logic [7:0] data;
    logic valid;
endinterface

module test_interface_value_sync;
    logic clk = 0;
    logic [7:0] test_data;
    logic test_valid;
    int errors = 0;

    // Interface instance with port connection
    data_bus bus(clk);

    initial begin
        $display("=== Interface Value Sync Test ===");
        $display("IEEE 1800-2023: Signal value propagation through interfaces");
        $display("");

        // Initialize
        bus.data = 8'h00;
        bus.valid = 0;
        test_data = 8'h00;
        test_valid = 0;

        // Test 1: Clock signal propagation
        $display("Test 1: Clock signal propagation");
        clk = 0;
        #1;
        if (bus.clk !== 0) begin
            $display("FAIL: bus.clk=%b, expected 0", bus.clk);
            errors++;
        end else begin
            $display("PASS: bus.clk=%b after clk=0", bus.clk);
        end

        clk = 1;
        #1;
        if (bus.clk !== 1) begin
            $display("FAIL: bus.clk=%b, expected 1", bus.clk);
            errors++;
        end else begin
            $display("PASS: bus.clk=%b after clk=1", bus.clk);
        end

        // Test 2: Multiple clock toggles
        $display("");
        $display("Test 2: Multiple clock toggles");
        for (int i = 0; i < 4; i++) begin
            clk = ~clk;
            #1;
            if (bus.clk !== clk) begin
                $display("FAIL: Iteration %0d: bus.clk=%b != clk=%b", i, bus.clk, clk);
                errors++;
            end
        end
        $display("PASS: Clock toggles synchronized correctly");

        // Test 3: Data signal assignment
        $display("");
        $display("Test 3: Data signal assignment");
        bus.data = 8'hAB;
        bus.valid = 1;
        #1;
        if (bus.data !== 8'hAB) begin
            $display("FAIL: bus.data=0x%h, expected 0xAB", bus.data);
            errors++;
        end else begin
            $display("PASS: bus.data=0x%h", bus.data);
        end

        if (bus.valid !== 1) begin
            $display("FAIL: bus.valid=%b, expected 1", bus.valid);
            errors++;
        end else begin
            $display("PASS: bus.valid=%b", bus.valid);
        end

        // Summary
        $display("");
        if (errors == 0) begin
            $display("TEST PASSED: Interface value sync works correctly");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end

        $finish;
    end
endmodule
