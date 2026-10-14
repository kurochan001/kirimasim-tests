/*
:name: test_interface_clock_and_signals
:description: Interface instance: drive a clock and write its variables from the instantiating module (IEEE 1800-2023 Sections 25.3 and 25.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_clock_and_signals.expected
*/
// Interface instance: driving a clock and writing its variables from the
// instantiating module (IEEE 1800-2023 Sections 25.3 and 25.5)

interface simple_if;
    logic clk;
    logic reset;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport master (
        input clk, reset,
        output data, valid,
        input ready
    );

    modport slave (
        input clk, reset,
        input data, valid,
        output ready
    );
endinterface

module test_interface_clock_and_signals;
    int pass_count = 0;
    int fail_count = 0;

    simple_if the_if();

    // Clock generation
    always #5 the_if.clk = ~the_if.clk;

    initial begin
        $display("=== Interface Clock and Signals Test ===");

        // Initialize interface signals
        the_if.clk = 0;
        the_if.reset = 0;
        the_if.data = 8'h00;
        the_if.valid = 0;
        the_if.ready = 0;

        // Test 1: Interface instantiation
        $display("Test 1: Interface instantiation");
        if (the_if.data == 8'h00) begin
            $display("Test 1 PASS: Interface data initialized to 0");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: Unexpected initial value");
            fail_count++;
        end

        // Test 2: Write to interface signal
        $display("Test 2: Write to interface signal");
        the_if.data = 8'hAB;
        #1;
        if (the_if.data == 8'hAB) begin
            $display("Test 2 PASS: Data written correctly (0x%0h)", the_if.data);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: Expected 0xAB, got 0x%0h", the_if.data);
            fail_count++;
        end

        // Test 3: Clock signal
        $display("Test 3: Clock toggle");
        @(posedge the_if.clk);
        if (the_if.clk == 1'b1) begin
            $display("Test 3 PASS: Clock toggled to high");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: Clock not high");
            fail_count++;
        end

        // Test 4: Multiple signal writes
        $display("Test 4: Multiple signal writes");
        the_if.valid = 1'b1;
        the_if.ready = 1'b1;
        the_if.data = 8'hCD;
        #1;
        if (the_if.valid && the_if.ready && the_if.data == 8'hCD) begin
            $display("Test 4 PASS: All signals written correctly");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Signal values incorrect");
            fail_count++;
        end

        // Test 5: Reset signal
        $display("Test 5: Reset signal toggle");
        the_if.reset = 1'b1;
        #1;
        if (the_if.reset == 1'b1) begin
            $display("Test 5 PASS: Reset signal high");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Reset not high");
            fail_count++;
        end

        // Summary
        $display("");
        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
