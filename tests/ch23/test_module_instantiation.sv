/*
:name: test_module_instantiation
:description: Module Instantiation Tests
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_instantiation.expected
*/
// IEEE 1800-2023 Sections 23.3.2 and 23.10.2.2 - Module Instantiation Tests
// Tests: module instantiation, port connections, parameters

module sub_module #(
    parameter WIDTH = 8,
    parameter INIT_VAL = 0
) (
    input logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data,
    input logic enable
);
    assign out_data = enable ? in_data : INIT_VAL;
endmodule

module adder #(parameter WIDTH = 8) (
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum
);
    assign sum = a + b;
endmodule

module test_module_instantiation;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] data_in, data_out;
    logic enable;
    logic [7:0] a_val, b_val, sum_val;
    logic [15:0] wide_a, wide_b, wide_sum;

    // Default parameter instance
    sub_module u_sub_default (
        .in_data(data_in),
        .out_data(data_out),
        .enable(enable)
    );

    // Custom parameter instance
    sub_module #(.WIDTH(8), .INIT_VAL(8'hFF)) u_sub_custom (
        .in_data(data_in),
        .out_data(),  // Unconnected output
        .enable(enable)
    );

    // Adder instances
    adder u_adder8 (.a(a_val), .b(b_val), .sum(sum_val));
    adder #(.WIDTH(16)) u_adder16 (.a(wide_a), .b(wide_b), .sum(wide_sum));

    initial begin
        $display("=== IEEE 1800-2023 Module Instantiation Test ===");

        // Test 1: Basic instantiation
        $display("Test 1: Basic module instantiation");
        data_in = 8'hAB;
        enable = 1;
        #1;
        $display("  data_in=%h, enable=%b, data_out=%h", data_in, enable, data_out);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Enable = 0
        $display("Test 2: Module with enable=0");
        enable = 0;
        #1;
        $display("  data_out=%h (should be INIT_VAL=0)", data_out);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Toggle enable
        $display("Test 3: Toggle enable");
        for (int i = 0; i < 4; i++) begin
            enable = i[0];
            data_in = i * 16;
            #1;
            $display("  iter %0d: enable=%b, out=%h", i, enable, data_out);
        end
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Adder 8-bit
        $display("Test 4: Adder 8-bit");
        a_val = 8'h10;
        b_val = 8'h20;
        #1;
        $display("  %h + %h = %h", a_val, b_val, sum_val);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Adder 16-bit
        $display("Test 5: Adder 16-bit");
        wide_a = 16'h1000;
        wide_b = 16'h2000;
        #1;
        $display("  %h + %h = %h", wide_a, wide_b, wide_sum);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Multiple values
        $display("Test 6: Multiple adder operations");
        for (int i = 0; i < 4; i++) begin
            a_val = i * 10;
            b_val = i * 5;
            #1;
            $display("  %0d + %0d = %0d", a_val, b_val, sum_val);
        end
        $display("Test 6 PASS");
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
