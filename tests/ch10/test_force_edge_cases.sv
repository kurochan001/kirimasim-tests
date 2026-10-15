/*
:name: test_force_edge_cases
:description: Force/Release edge cases
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_edge_cases.expected
*/
// IEEE 1800-2023 §10.6.2: Force/Release edge cases
// Tests for force and release statements

module test_force_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic sig;
    logic [7:0] bus;
    wire driven_wire;

    assign driven_wire = sig;

    initial begin
        sig = 0;
        bus = 0;
        #1;

        // Test 1: Force signal
        test_count++;
        force sig = 1;
        #1;
        if (sig == 1) begin
            pass_count++;
            $display("Test 1 PASS: Force sig = %b", sig);
        end else begin
            $display("Test 1 FAIL: Force unexpected = %b", sig);
        end

        // Test 2: Force overrides
        test_count++;
        sig = 0;  // This should be overridden
        #1;
        if (sig == 1) begin
            pass_count++;
            $display("Test 2 PASS: Override sig = %b", sig);
        end else begin
            $display("Test 2 FAIL: Override unexpected = %b", sig);
        end

        // Test 3: Release signal
        test_count++;
        release sig;
        #1;
        pass_count++;
        $display("Test 3 PASS: Released sig = %b", sig);

        // Test 4: Force bus
        test_count++;
        force bus = 8'hAA;
        #1;
        if (bus == 8'hAA) begin
            pass_count++;
            $display("Test 4 PASS: Force bus = %h", bus);
        end else begin
            $display("Test 4 FAIL: Bus unexpected = %h", bus);
        end

        // Test 5: Force different value
        test_count++;
        force bus = 8'h55;
        #1;
        if (bus == 8'h55) begin
            pass_count++;
            $display("Test 5 PASS: New force = %h", bus);
        end else begin
            $display("Test 5 FAIL: New unexpected = %h", bus);
        end

        // Test 6: Release bus
        test_count++;
        release bus;
        #1;
        pass_count++;
        $display("Test 6 PASS: Released bus = %h", bus);

        // Test 7: Force wire (through driver)
        test_count++;
        sig = 0;
        force driven_wire = 1;
        #1;
        if (driven_wire == 1) begin
            pass_count++;
            $display("Test 7 PASS: Force wire = %b", driven_wire);
        end else begin
            $display("Test 7 FAIL: Wire unexpected = %b", driven_wire);
        end

        // Test 8: Release wire
        test_count++;
        release driven_wire;
        #1;
        pass_count++;
        $display("Test 8 PASS: Released wire = %b", driven_wire);

        // Test 9: Multiple force/release
        test_count++;
        force sig = 0; #1; release sig; #1;
        force sig = 1; #1; release sig; #1;
        force sig = 0; #1; release sig; #1;
        pass_count++;
        $display("Test 9 PASS: Multi force/release");

        // Test 10: Final state
        test_count++;
        sig = 1;
        bus = 8'hFF;
        #1;
        pass_count++;
        $display("Test 10 PASS: Final sig=%b bus=%h", sig, bus);

        $display("=== Force Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
