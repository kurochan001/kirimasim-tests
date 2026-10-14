/*
:name: test_module_instance_param_override
:description: Module instances with named ports and a parameter override (IEEE 1800-2023 Sections 23.3.2.2 and 23.10.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.2 23.10.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_instance_param_override.expected
*/
// IEEE 1800-2023 Sections 23.3.2.2 and 23.10.2.2 - Module instances with named ports and a parameter override
// Tests: named ports, parameter override, result width
module sub_mod #(
    parameter int WIDTH = 8
)(
    input logic [WIDTH-1:0] in_a,
    input logic [WIDTH-1:0] in_b,
    output logic [WIDTH-1:0] out_sum
);
    assign out_sum = in_a + in_b;
endmodule

module test_module_instance_param_override;
    int passed = 0;
    int failed = 0;

    logic [7:0] a8, b8, sum8;
    logic [15:0] a16, b16, sum16;

    // Named port connection
    sub_mod u_named (
        .in_a(a8),
        .in_b(b8),
        .out_sum(sum8)
    );

    // Parameter override
    sub_mod #(.WIDTH(16)) u_wide (
        .in_a(a16),
        .in_b(b16),
        .out_sum(sum16)
    );

    initial begin
        // Test named ports default width
        a8 = 8'd10;
        b8 = 8'd20;
        #1;
        if (sum8 == 8'd30) passed++; else begin failed++; $display("FAIL: named sum = %0d", sum8); end

        // Test parameter override
        a16 = 16'd1000;
        b16 = 16'd2000;
        #1;
        if (sum16 == 16'd3000) passed++; else begin failed++; $display("FAIL: wide sum = %0d", sum16); end

        // Test overflow
        a8 = 8'd200;
        b8 = 8'd100;
        #1;
        if (sum8 == 8'd44) passed++; else begin failed++; $display("FAIL: overflow = %0d", sum8); end  // 300 mod 256 = 44

        // Report
        if (failed == 0)
            $display("PASS: All %0d module tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
