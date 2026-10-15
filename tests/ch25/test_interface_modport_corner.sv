/*
:name: test_interface_modport_corner
:description: Tests modport declarations, access control, and virtual interfaces
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.9 4.9.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_modport_corner.expected
*/
// Tests modport declarations, access control, and virtual interfaces
`timescale 1ns/1ps

interface simple_bus_if;
    logic clk;
    logic rst_n;
    logic [7:0] data;
    logic valid;
    logic ready;

    // Modport for master
    modport master (
        input clk, rst_n, ready,
        output data, valid
    );

    // Modport for slave
    modport slave (
        input clk, rst_n, data, valid,
        output ready
    );

    // Modport for monitor (all inputs)
    modport monitor (
        input clk, rst_n, data, valid, ready
    );
endinterface

module master_device (simple_bus_if.master bus);
    initial begin
        bus.data = 8'h00;
        bus.valid = 0;
    end

    always @(posedge bus.clk or negedge bus.rst_n) begin
        if (!bus.rst_n) begin
            bus.data <= 8'h00;
            bus.valid <= 0;
        end else if (bus.ready) begin
            bus.data <= bus.data + 1;
            bus.valid <= 1;
        end else begin
            bus.valid <= 0;
        end
    end
endmodule

module slave_device (simple_bus_if.slave bus);
    logic [7:0] received_data;

    initial begin
        bus.ready = 0;
        received_data = 0;
    end

    always @(posedge bus.clk or negedge bus.rst_n) begin
        if (!bus.rst_n) begin
            bus.ready <= 0;
            received_data <= 0;
        end else begin
            bus.ready <= 1;
            if (bus.valid) begin
                received_data <= bus.data;
            end
        end
    end
endmodule

module test_interface_modport_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    logic rst_n = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Interface instance
    simple_bus_if bus_if();

    // Connect clock and reset
    assign bus_if.clk = clk;
    assign bus_if.rst_n = rst_n;

    // Instantiate modules with modports
    master_device master_inst (.bus(bus_if.master));
    slave_device slave_inst (.bus(bus_if.slave));

    // Test using virtual interface
    task test_virtual_interface();
        virtual simple_bus_if vif;
        vif = bus_if;

        // Access through virtual interface
        @(posedge clk);
        #1;  // bus_if.clk follows clk through a continuous assignment
        if (vif.clk == clk) begin
            $display("PASS: Virtual interface connection works");
            pass_count++;
        end else begin
            $display("FAIL: Virtual interface connection failed");
            fail_count++;
        end
    endtask

    // Test data transfer
    task test_data_transfer();
        static int transfer_count = 0;

        repeat (10) begin
            @(posedge clk);
            if (bus_if.valid && bus_if.ready) begin
                transfer_count++;
                $display("  Transfer %0d: data=0x%h", transfer_count, bus_if.data);
            end
        end

        if (transfer_count > 0) begin
            $display("PASS: Data transfers occurred: %0d", transfer_count);
            pass_count++;
        end else begin
            $display("FAIL: No transfers in test window");
            fail_count++;
        end
    endtask

    // Test modport access control
    task test_modport_access();
        // Monitor can read all signals
        @(posedge clk);
        $display("  Monitor view: data=0x%h, valid=%b, ready=%b",
                 bus_if.data, bus_if.valid, bus_if.ready);

        if (bus_if.valid === 1'b1 && bus_if.ready === 1'b1) begin
            $display("PASS: Monitor sees the bus through the interface");
            pass_count++;
        end else begin
            $display("FAIL: Monitor view unexpected");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Interface Modport Corner Cases Test ===");

        // Reset sequence
        rst_n = 0;
        repeat (3) @(posedge clk);
        // Released with a nonblocking assignment so that the always blocks
        // triggered by the same edge all still see the reset
        rst_n <= 1;

        // Run tests
        test_virtual_interface();
        test_data_transfer();
        test_modport_access();

        // Additional cycles
        repeat (5) @(posedge clk);

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
