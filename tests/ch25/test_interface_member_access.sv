/*
:name: test_interface_member_access
:description: Reading and writing interface signals through the instance name
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_member_access.expected
*/
// IEEE 1800-2023 Section 25 - Interface and Modport Tests
// Tests: interfaces, modports, virtual interfaces

interface simple_bus;
    logic [7:0] data;
    logic valid;
    logic ready;

    modport master (
        output data, valid,
        input ready
    );

    modport slave (
        input data, valid,
        output ready
    );
endinterface

module test_interface_member_access;
    int pass_count = 0;
    int fail_count = 0;

    simple_bus bus();

    initial begin
        $display("=== IEEE 1800-2023 Interface and Modport Test ===");

        // Test 1: Interface signal access
        $display("Test 1: Interface signal access");
        bus.data = 8'hAB;
        bus.valid = 1;
        bus.ready = 0;
        $display("  data=%h, valid=%b, ready=%b", bus.data, bus.valid, bus.ready);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Interface signal modification
        $display("Test 2: Interface signal modification");
        bus.data = 8'hCD;
        $display("  modified data=%h", bus.data);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Multiple assignments
        $display("Test 3: Multiple assignments");
        for (int i = 0; i < 4; i++) begin
            bus.data = i * 16;
            #1;
            $display("  iter %0d: data=%h", i, bus.data);
        end
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Valid/ready handshake simulation
        $display("Test 4: Valid/ready handshake");
        bus.valid = 1;
        bus.data = 8'hEF;
        #1;
        bus.ready = 1;
        #1;
        bus.valid = 0;
        bus.ready = 0;
        $display("  Handshake completed");
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Interface reset
        $display("Test 5: Interface reset");
        bus.data = 8'h00;
        bus.valid = 0;
        bus.ready = 0;
        $display("  After reset: data=%h", bus.data);
        $display("Test 5 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
