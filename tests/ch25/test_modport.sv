/*
:name: test_modport
:description: Modports
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport.expected
*/
// IEEE 1800-2023 §25.4: Modports
// Tests modport declarations and access restrictions
// Verifies directional port constraints

interface bus_if;
    logic clk;
    logic [7:0] data;
    logic valid;
    logic ready;

    // Master modport - can drive data and valid
    modport master (
        input clk,
        output data,
        output valid,
        input ready
    );

    // Slave modport - can drive ready
    modport slave (
        input clk,
        input data,
        input valid,
        output ready
    );

    // Monitor modport - read-only access
    modport monitor (
        input clk,
        input data,
        input valid,
        input ready
    );
endinterface

module master_mod(bus_if.master bus);
    initial begin
        bus.data = 8'hAA;
        bus.valid = 1;
    end
endmodule

module slave_mod(bus_if.slave bus);
    initial begin
        bus.ready = 1;
    end
endmodule

module test_modport;
    int pass_count = 0;
    int fail_count = 0;

    bus_if bus();

    master_mod u_master(.bus(bus));
    slave_mod u_slave(.bus(bus));

    initial begin
        $display("=== IEEE 1800-2023 §25.4: Modports ===");

        bus.clk = 0;
        #1;

        // Test 1: Master can write data
        if (bus.data == 8'hAA) begin
            $display("PASS: Master wrote data = 0xAA");
            pass_count++;
        end else begin
            $display("FAIL: data = %h", bus.data);
            fail_count++;
        end

        // Test 2: Master can write valid
        if (bus.valid == 1) begin
            $display("PASS: Master wrote valid = 1");
            pass_count++;
        end else begin
            $display("FAIL: valid = %0d", bus.valid);
            fail_count++;
        end

        // Test 3: Slave can write ready
        if (bus.ready == 1) begin
            $display("PASS: Slave wrote ready = 1");
            pass_count++;
        end else begin
            $display("FAIL: ready = %0d", bus.ready);
            fail_count++;
        end

        // Test 4: Interface signals accessible from testbench
        bus.data = 8'hBB;
        if (bus.data == 8'hBB) begin
            $display("PASS: Testbench can access interface signals");
            pass_count++;
        end else begin
            $display("FAIL: Interface access failed");
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
