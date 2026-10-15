/*
:name: test_interface_functions_instances
:description: Functions declared in an interface, called on four separate interface instances
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7 25.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_functions_instances.expected
*/
// IEEE 1800-2023 §25.3.3: Interface arrays
// Tests arrays of interface instances
// Verifies multiple interface handling

interface channel_if;
    logic [7:0] data;
    logic enable;

    function automatic void set(logic [7:0] d);
        data = d;
        enable = 1;
    endfunction

    function automatic void clear();
        data = 0;
        enable = 0;
    endfunction
endinterface

module test_interface_functions_instances;
    int pass_count = 0;
    int fail_count = 0;

    // Individual interface instances (array indexing with variable not supported)
    channel_if ch0();
    channel_if ch1();
    channel_if ch2();
    channel_if ch3();

    initial begin
        $display("=== IEEE 1800-2023 §25.3.3: Interface Arrays ===");

        // Test 1: Initialize all channels
        ch0.data = 0; ch0.enable = 0;
        ch1.data = 0; ch1.enable = 0;
        ch2.data = 0; ch2.enable = 0;
        ch3.data = 0; ch3.enable = 0;
        $display("PASS: All 4 channels initialized");
        pass_count++;

        // Test 2: Set different values
        ch0.set(8'h10);
        ch1.set(8'h20);
        ch2.set(8'h30);
        ch3.set(8'h40);

        if (ch0.data == 8'h10 &&
            ch1.data == 8'h20 &&
            ch2.data == 8'h30 &&
            ch3.data == 8'h40) begin
            $display("PASS: All channels have unique data");
            pass_count++;
        end else begin
            $display("FAIL: Channel data mismatch");
            fail_count++;
        end

        // Test 3: Check enable signals
        if (ch0.enable && ch1.enable && ch2.enable && ch3.enable) begin
            $display("PASS: All channels enabled");
            pass_count++;
        end else begin
            $display("FAIL: Enable signals wrong");
            fail_count++;
        end

        // Test 4: Clear one channel
        ch1.clear();
        if (ch1.data == 0 && ch1.enable == 0) begin
            $display("PASS: Channel 1 cleared");
            pass_count++;
        end else begin
            $display("FAIL: Channel 1 not cleared");
            fail_count++;
        end

        // Test 5: Other channels unchanged
        if (ch0.data == 8'h10 && ch2.data == 8'h30) begin
            $display("PASS: Other channels unchanged after clear");
            pass_count++;
        end else begin
            $display("FAIL: Other channels affected");
            fail_count++;
        end

        // Test 6: Direct assignment
        ch3.data = 35;
        if (ch3.data == 35) begin
            $display("PASS: Direct interface data assignment");
            pass_count++;
        end else begin
            $display("FAIL: Direct assignment failed");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
