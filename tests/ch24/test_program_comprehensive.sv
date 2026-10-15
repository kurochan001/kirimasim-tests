/*
:name: test_program_comprehensive
:description: Chapter 24: Programs - Comprehensive Test
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 24.2 4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_comprehensive.expected
*/
// IEEE 1800-2023 Chapter 24: Programs - Comprehensive Test
// Tests: §24.2 Program construct, §24.3 Program variables

// Simple DUT module
module simple_dut(
    input logic clk,
    input logic rst_n,
    input logic [7:0] data_in,
    output logic [7:0] data_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'h00;
        else
            data_out <= data_in + 1;
    end
endmodule

// §24.2: Program construct - testbench
program automatic test_program(
    input logic clk,
    output logic rst_n,
    output logic [7:0] data_in,
    input logic [7:0] data_out
);
    // §24.3: Program variables
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        rst_n = 0;
        data_in = 0;

        // Reset sequence
        repeat(3) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        $display("Starting Program Block Tests...");

        // Test 1: Basic transaction
        @(posedge clk);
        data_in = 8'h10;

        @(posedge clk);
        @(posedge clk);

        if (data_out == 8'h11) begin
            $display("PASS: Basic transaction (0x10 + 1 = 0x11)");
            pass_count++;
        end else begin
            $display("FAIL: Basic transaction: got 0x%h, expected 0x11", data_out);
            fail_count++;
        end

        // Test 2: Multiple values
        @(posedge clk);
        data_in = 8'h20;

        @(posedge clk);
        @(posedge clk);

        if (data_out == 8'h21) begin
            $display("PASS: Second transaction");
            pass_count++;
        end else begin
            $display("FAIL: Second transaction");
            fail_count++;
        end

        // Test 3: Program local variable
        begin
            automatic int local_var = 100;
            if (local_var == 100) begin
                $display("PASS: Program local variable");
                pass_count++;
            end else begin
                $display("FAIL: Program local variable");
                fail_count++;
            end
        end

        // Summary
        repeat(3) @(posedge clk);

        $display("");
        $display("=================================");
        $display("Program Block Tests: %0d passed, %0d failed", pass_count, fail_count);
        $display("=================================");

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endprogram

// Top-level module
module test;
    logic clk = 0;
    always #5 clk = ~clk;

    logic rst_n;
    logic [7:0] data_in, data_out;

    // DUT instance
    simple_dut dut(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Program instance
    test_program tb(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );
endmodule
