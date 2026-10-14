/*
:name: test_interface_parameters
:description: Parameterized interfaces
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_parameters.expected
*/
// IEEE 1800-2023 §25.3: Parameterized interfaces
// Tests interface with parameters
// Verifies parameter-dependent signal widths

interface data_bus_if #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
);
    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;
    logic valid;
    logic ready;
endinterface

module test_interface_parameters;
    int pass_count = 0;
    int fail_count = 0;

    // Default parameters
    data_bus_if bus_default();

    // Wide data bus
    data_bus_if #(.WIDTH(16)) bus_wide();

    // Custom both
    data_bus_if #(.WIDTH(32), .DEPTH(8)) bus_custom();

    initial begin
        $display("=== IEEE 1800-2023 §25.3: Parameterized Interfaces ===");

        // Test 1: Default interface data assignment
        bus_default.data = 8'hFF;
        if (bus_default.data == 8'hFF) begin
            $display("PASS: Default interface data = 0xFF");
            pass_count++;
        end else begin
            $display("FAIL: Default data = %h", bus_default.data);
            fail_count++;
        end

        // Test 2: Default interface valid/ready
        bus_default.valid = 1;
        bus_default.ready = 1;
        if (bus_default.valid && bus_default.ready) begin
            $display("PASS: Default valid/ready work");
            pass_count++;
        end else begin
            $display("FAIL: valid/ready failed");
            fail_count++;
        end

        // Test 3: Wide interface data
        bus_wide.data = 16'hABCD;
        if (bus_wide.data == 16'hABCD) begin
            $display("PASS: Wide interface data = 0xABCD");
            pass_count++;
        end else begin
            $display("FAIL: Wide data = %h", bus_wide.data);
            fail_count++;
        end

        // Test 4: Custom interface data
        bus_custom.data = 32'h12345678;
        if (bus_custom.data == 32'h12345678) begin
            $display("PASS: Custom interface data = 0x12345678");
            pass_count++;
        end else begin
            $display("FAIL: Custom data = %h", bus_custom.data);
            fail_count++;
        end

        // Test 5: Custom interface addr
        bus_custom.addr = 8'hAA;
        if (bus_custom.addr == 8'hAA) begin
            $display("PASS: Custom interface addr = 0xAA");
            pass_count++;
        end else begin
            $display("FAIL: Custom addr = %h", bus_custom.addr);
            fail_count++;
        end

        // Test 6: Independent interfaces
        if (bus_default.data != bus_wide.data) begin
            $display("PASS: Interfaces are independent");
            pass_count++;
        end else begin
            $display("FAIL: Interfaces share state");
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
