/*
:name: test_interface_basic_2
:description: Chapter 25: Interfaces
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_basic_2.expected
*/
// IEEE 1800-2023 Chapter 25: Interfaces
// §25.3 Interface syntax and basic usage

`timescale 1ns/1ps

// Simple interface definition
interface simple_if;
    logic clk;
    logic reset;
    logic [7:0] data;
    logic valid;
    logic ready;
endinterface

module test_interface_basic_2;
    // Test basic interface instantiation and access

    int test_count;
    int pass_count;

    // Instantiate interface
    simple_if bus();

    // Connect modules through interface
    producer u_prod(bus);
    consumer u_cons(bus);

    initial begin
        test_count = 0;
        pass_count = 0;
        bus.clk = 0;
        bus.reset = 1;
        bus.data = 0;
        bus.valid = 0;
        bus.ready = 1;

        // Test 1: Reset state
        #5;
        bus.reset = 0;
        #5;
        bus.clk = 1;
        #5;
        bus.clk = 0;
        test_count++;
        if (bus.data == 0) pass_count++;
        else $display("FAIL: Reset state - data=%0d (expected 0)", bus.data);

        // Test 2: Interface signal assignment
        bus.data = 8'hAB;
        bus.valid = 1;
        #5;
        bus.clk = 1;
        #5;
        bus.clk = 0;
        test_count++;
        if (bus.data == 8'hAB && bus.valid == 1) pass_count++;
        else $display("FAIL: Signal assign - data=0x%0h, valid=%0d", bus.data, bus.valid);

        // Test 3: Consumer received data
        test_count++;
        if (u_cons.received_data == 8'hAB) pass_count++;
        else $display("FAIL: Consumer - received=0x%0h (expected 0xAB)", u_cons.received_data);

        $display("Chapter 25.3 Interface Basic: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule

module producer(simple_if bus);
    // Producer writes to interface
    initial begin
        @(negedge bus.reset);
        @(posedge bus.clk);
        // Data is set by testbench in this test
    end
endmodule

module consumer(simple_if bus);
    // Consumer reads from interface
    logic [7:0] received_data;

    always @(posedge bus.clk) begin
        if (!bus.reset && bus.valid && bus.ready) begin
            received_data <= bus.data;
        end
    end
endmodule
