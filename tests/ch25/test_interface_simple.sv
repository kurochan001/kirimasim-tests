/*
:name: test_interface_simple
:description: Interface Tests
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_simple.expected
*/
// IEEE 1800-2023 Section 25 - Interface Tests
interface simple_if;
    logic [7:0] data;
    logic valid;
endinterface

module test_interface_simple;
    int pass_count = 0;
    int fail_count = 0;
    simple_if sif();

    initial begin
        $display("=== IEEE 1800-2023 Interface Tests ===");

        // Test 1: Initial data
        $display("Test 1: Init data");
        sif.data = 8'h55;
        #1;
        if (sif.data == 8'h55) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", sif.data); fail_count++; end

        // Test 2: Valid signal
        $display("Test 2: Valid");
        sif.valid = 1'b1;
        #1;
        if (sif.valid == 1'b1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %b", sif.valid); fail_count++; end

        // Test 3: Clear valid
        $display("Test 3: Clear");
        sif.valid = 1'b0;
        #1;
        if (sif.valid == 1'b0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %b", sif.valid); fail_count++; end

        // Test 4: Update data
        $display("Test 4: Update");
        sif.data = 8'hAA;
        #1;
        if (sif.data == 8'hAA) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", sif.data); fail_count++; end

        // Test 5: Zero data
        $display("Test 5: Zero");
        sif.data = 8'h00;
        #1;
        if (sif.data == 8'h00) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", sif.data); fail_count++; end

        // Test 6: Full data
        $display("Test 6: Full");
        sif.data = 8'hFF;
        #1;
        if (sif.data == 8'hFF) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", sif.data); fail_count++; end

        // Test 7: Both signals
        $display("Test 7: Both");
        sif.data = 8'h12;
        sif.valid = 1'b1;
        #1;
        if (sif.data == 8'h12 && sif.valid == 1'b1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Pattern
        $display("Test 8: Pattern");
        sif.data = 8'b10101010;
        #1;
        if (sif.data == 8'hAA) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", sif.data); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
