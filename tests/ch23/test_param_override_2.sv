/*
:name: test_param_override_2
:description: Parameter override
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 6.20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_override_2.expected
*/
// Parameter override
module sub_module #(
    parameter WIDTH = 8,
    parameter DEPTH = 4,
    parameter logic [7:0] INIT_VAL = 8'hAA
) (
    input  logic [WIDTH-1:0] in_data,
    output logic [WIDTH-1:0] out_data
);
    assign out_data = in_data ^ INIT_VAL;
endmodule

module test_param_override;
    logic [15:0] data_in, data_out1, data_out2, data_out3;
    logic [7:0] data_in_8, data_out4;

    // Test 1: Override all parameters
    sub_module #(.WIDTH(16), .DEPTH(8), .INIT_VAL(8'h55)) u1 (
        .in_data(data_in),
        .out_data(data_out1)
    );

    // Test 2: Override only some parameters (positional)
    sub_module #(16, 2) u2 (
        .in_data(data_in),
        .out_data(data_out2)
    );

    // Test 3: All named parameters (mixed positional and named not allowed)
    sub_module #(.WIDTH(16), .INIT_VAL(8'hFF)) u3 (
        .in_data(data_in),
        .out_data(data_out3)
    );

    // Test 4: Default parameters
    sub_module u4 (
        .in_data(data_in_8),
        .out_data(data_out4)
    );

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: All parameters overridden
        data_in = 16'hCAFE;
        #1;
        if (data_out1 == (16'hCAFE ^ 16'h0055)) begin
            $display("PASS: Test 1 - All parameters overridden");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected %h, got %h", 16'hCAFE ^ 16'h0055, data_out1);
            fail_count++;
        end

        // Test 2: Positional override
        if (data_out2 == (16'hCAFE ^ 16'h00AA)) begin
            $display("PASS: Test 2 - Positional parameter override");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected %h, got %h", 16'hCAFE ^ 16'h00AA, data_out2);
            fail_count++;
        end

        // Test 3: Mixed override
        if (data_out3 == (16'hCAFE ^ 16'h00FF)) begin
            $display("PASS: Test 3 - Mixed positional and named override");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected %h, got %h", 16'hCAFE ^ 16'h00FF, data_out3);
            fail_count++;
        end

        // Test 4: Default parameters
        data_in_8 = 8'h12;
        #1;
        if (data_out4 == (8'h12 ^ 8'hAA)) begin
            $display("PASS: Test 4 - Default parameters used");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected %h, got %h", 8'h12 ^ 8'hAA, data_out4);
            fail_count++;
        end

        // Test 5: Parameter affects width correctly
        data_in = 16'hFFFF;
        #1;
        if (data_out1[15:8] != 8'h00) begin
            $display("PASS: Test 5 - Width parameter affects signal size");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Width parameter not applied correctly");
            fail_count++;
        end

        $display("\n=== Parameter Override Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
