/*
:name: test_module_parameter_corner
:description: Named and positional parameter overrides, and a localparam computed with $clog2
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 6.20.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_parameter_corner.expected
*/
// Named and positional parameter overrides, and a localparam computed with $clog2
`timescale 1ns/1ps

module parameterized_mod #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4,
    parameter logic [7:0] INIT_VAL = 8'h00,
    parameter string NAME = "default"
) (
    input logic clk,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    localparam int ADDR_WIDTH = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [DEPTH];

    always @(posedge clk) begin
        data_out <= data_in;
    end
endmodule

module test_module_parameter_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    // Default parameters
    logic [7:0] data1_in, data1_out;
    parameterized_mod mod1 (
        .clk(clk),
        .data_in(data1_in),
        .data_out(data1_out)
    );

    // Override WIDTH
    logic [15:0] data2_in, data2_out;
    parameterized_mod #(.WIDTH(16)) mod2 (
        .clk(clk),
        .data_in(data2_in),
        .data_out(data2_out)
    );

    // Override multiple parameters
    logic [31:0] data3_in, data3_out;
    parameterized_mod #(
        .WIDTH(32),
        .DEPTH(16),
        .INIT_VAL(8'hAA),
        .NAME("mod3")
    ) mod3 (
        .clk(clk),
        .data_in(data3_in),
        .data_out(data3_out)
    );

    // Override by position
    logic [3:0] data4_in, data4_out;
    parameterized_mod #(4, 8, 8'hBB, "mod4") mod4 (
        .clk(clk),
        .data_in(data4_in),
        .data_out(data4_out)
    );

    // Test 1: Default parameters work
    task test_default_params();
        data1_in = 8'hAB;
        @(posedge clk);
        @(posedge clk);

        if (data1_out == 8'hAB) begin
            $display("PASS: Default parameters work");
            pass_count++;
        end else begin
            $display("FAIL: Default parameters failed");
            fail_count++;
        end
    endtask

    // Test 2: Width override
    task test_width_override();
        data2_in = 16'hCAFE;
        @(posedge clk);
        @(posedge clk);

        if (data2_out == 16'hCAFE) begin
            $display("PASS: WIDTH override works");
            pass_count++;
        end else begin
            $display("FAIL: WIDTH override failed");
            fail_count++;
        end
    endtask

    // Test 3: Multiple parameter override
    task test_multiple_override();
        data3_in = 32'hDEADBEEF;
        @(posedge clk);
        @(posedge clk);

        if (data3_out == 32'hDEADBEEF) begin
            $display("PASS: Multiple parameter override works");
            pass_count++;
        end else begin
            $display("FAIL: Multiple parameter override failed");
            fail_count++;
        end
    endtask

    // Test 4: Positional override
    task test_positional_override();
        data4_in = 4'hC;
        @(posedge clk);
        @(posedge clk);

        if (data4_out == 4'hC) begin
            $display("PASS: Positional parameter override works");
            pass_count++;
        end else begin
            $display("FAIL: Positional override failed");
            fail_count++;
        end
    endtask

    // Test 5: Localparam calculation
    task test_localparam();
        // ADDR_WIDTH is $clog2(DEPTH): 2 for the default DEPTH of 4, 4 for 16.
        if (mod1.ADDR_WIDTH == 2 && mod3.ADDR_WIDTH == 4) begin
            $display("PASS: Localparam calculation verified");
            pass_count++;
        end else begin
            $display("FAIL: ADDR_WIDTH %0d %0d", mod1.ADDR_WIDTH, mod3.ADDR_WIDTH);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Module Parameter Corner Cases Test ===");
        // Printed here one after another: an initial block in each instance
        // would print at time 0 in no defined order (4.7).
        $display("  Module %s: WIDTH=%0d, DEPTH=%0d, INIT=%h", mod1.NAME, mod1.WIDTH, mod1.DEPTH, mod1.INIT_VAL);
        $display("  Module %s: WIDTH=%0d, DEPTH=%0d, INIT=%h", mod2.NAME, mod2.WIDTH, mod2.DEPTH, mod2.INIT_VAL);
        $display("  Module %s: WIDTH=%0d, DEPTH=%0d, INIT=%h", mod3.NAME, mod3.WIDTH, mod3.DEPTH, mod3.INIT_VAL);
        $display("  Module %s: WIDTH=%0d, DEPTH=%0d, INIT=%h", mod4.NAME, mod4.WIDTH, mod4.DEPTH, mod4.INIT_VAL);

        repeat (2) @(posedge clk);

        test_default_params();
        test_width_override();
        test_multiple_override();
        test_positional_override();
        test_localparam();

        repeat (3) @(posedge clk);

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
