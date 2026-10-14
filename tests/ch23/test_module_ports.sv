/*
:name: test_module_ports
:description: Chapter 23: Modules and hierarchy
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2 23.3.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_ports.expected
*/
// IEEE 1800-2023 Chapter 23: Modules and hierarchy
// §23.2.2 Port declarations and §23.3.2 Module instantiation

module test_module_ports;
    // Test various port declarations

    reg clk, reset;
    wire [7:0] data_out;
    reg [7:0] data_in;
    wire ready;

    int test_count;
    int pass_count;

    // Instantiate submodule with various port connections
    submod_ports u_sub (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .ready(ready)
    );

    initial begin
        test_count = 0;
        pass_count = 0;
        clk = 0;
        reset = 1;
        data_in = 0;

        // Test 1: Reset behavior
        #5;
        reset = 0;
        #5;
        clk = 1;
        #5;
        clk = 0;
        test_count++;
        if (data_out == 0 && ready == 1) pass_count++;
        else $display("FAIL: Reset state - data_out=%0d, ready=%0d", data_out, ready);

        // Test 2: Data pass-through
        data_in = 8'hAB;
        #5;
        clk = 1;
        #5;
        clk = 0;
        test_count++;
        if (data_out == 8'hAB) pass_count++;
        else $display("FAIL: Data pass-through - data_out=0x%0h (expected 0xAB)", data_out);

        // Test 3: Multiple data values
        data_in = 8'h55;
        #5;
        clk = 1;
        #5;
        clk = 0;
        test_count++;
        if (data_out == 8'h55) pass_count++;
        else $display("FAIL: Multiple data - data_out=0x%0h (expected 0x55)", data_out);

        $display("Chapter 23.2-3 Module Ports: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule

// Submodule with various port types
module submod_ports(
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output wire ready
);
    assign ready = !reset;

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 8'd0;
        else
            data_out <= data_in;
    end
endmodule
