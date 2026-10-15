/*
:name: test_modport_expressions
:description: Modport Expressions Tests
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5 25.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_expressions.expected
*/
// IEEE 1800-2023 Section 25.5 - Modport Expressions Tests
// Tests: modport declarations, clocking modports, export tasks

interface data_bus_if #(parameter WIDTH = 8);
    logic [WIDTH-1:0] data;
    logic valid;
    logic ready;
    logic [1:0] mode;

    // Modport for master
    modport master (
        output data, valid,
        input ready
    );

    // Modport for slave
    modport slave (
        input data, valid,
        output ready
    );

    // Modport with expressions
    modport master_mode (
        output .tx_data(data), .tx_valid(valid),
        input .tx_ready(ready),
        input mode
    );

endinterface

module master_device(data_bus_if.master bus);
    initial begin
        bus.data = 8'hAB;
        bus.valid = 1;
    end
endmodule

module slave_device(data_bus_if.slave bus);
    initial begin
        bus.ready = 1;
    end
endmodule

// Drives the bus through the renamed ports of the master_mode modport (25.5.4)
module mode_device(data_bus_if.master_mode bus);
    initial begin
        #10;
        bus.tx_data = 8'h5A;
        bus.tx_valid = 0;
    end
endmodule

module test_modport_expressions;
    int pass_count = 0;
    int fail_count = 0;

    // Interface instance
    data_bus_if #(.WIDTH(8)) bus_inst();

    // Module instances with modport connections
    master_device master(.bus(bus_inst.master));
    slave_device slave(.bus(bus_inst.slave));
    mode_device mode_dev(.bus(bus_inst.master_mode));

    initial begin
        $display("=== IEEE 1800-2023 Modport Expressions Tests ===");

        // Test 1: Basic modport instantiation
        $display("Test 1: Modport instantiation");
        #1;
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Master writes through modport
        $display("Test 2: Master write through modport");
        #1;
        if (bus_inst.data == 8'hAB) begin
            $display("Test 2 PASS");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: data=%h (expected AB)", bus_inst.data);
            fail_count++;
        end

        // Test 3: Valid signal through modport
        $display("Test 3: Valid signal through modport");
        if (bus_inst.valid == 1) begin
            $display("Test 3 PASS");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: valid=%b", bus_inst.valid);
            fail_count++;
        end

        // Test 4: Slave responds through modport
        $display("Test 4: Slave ready through modport");
        if (bus_inst.ready == 1) begin
            $display("Test 4 PASS");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: ready=%b", bus_inst.ready);
            fail_count++;
        end

        // Test 5: Mode access
        $display("Test 5: Mode signal access");
        bus_inst.mode = 2'b10;
        #1;
        if (bus_inst.mode == 2'b10) begin
            $display("Test 5 PASS");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: mode=%b", bus_inst.mode);
            fail_count++;
        end

        // Test 6: Data transfer sequence
        $display("Test 6: Data transfer sequence");
        bus_inst.data = 8'hCD;
        bus_inst.valid = 1;
        #1;
        if (bus_inst.data == 8'hCD && bus_inst.valid == 1 && bus_inst.ready == 1) begin
            $display("Test 6 PASS");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: write through modport expressions (tx_data, tx_valid)
        $display("Test 7: Modport expressions");
        #7;  // mode_device writes at time 10
        if (bus_inst.data == 8'h5A && bus_inst.valid == 0) begin
            $display("Test 7 PASS");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: data=%h valid=%b", bus_inst.data, bus_inst.valid);
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
