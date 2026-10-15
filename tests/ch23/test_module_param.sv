/*
:name: test_module_param
:description: Module parameters test
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 6.20.3 6.20.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_param.expected
*/
// Module parameters test
module test_module_param;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Default parameter values
    param_module_default pmd();

    // Test 2: Override parameter with #()
    param_module #(.WIDTH(16), .DEPTH(32)) pm_override();

    // Test 3: localparam (cannot be overridden)
    localparam_module lpm();

    // Test 4: Parameter with type
    type_param_module #(.T(logic [15:0])) tpm();

    // Test 5: Multiple parameters
    multi_param_module #(.A(100), .B(200), .C(8'hFF)) mpm();

    initial begin
        #1;

        // Test 1: Default parameter values
        if (pmd.WIDTH == 8 && pmd.DEPTH == 16) begin
            $display("PASS: Test 1 - Default parameters (%0d, %0d)", pmd.WIDTH, pmd.DEPTH);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Default parameters incorrect (%0d, %0d)", pmd.WIDTH, pmd.DEPTH);
            fail_count++;
        end

        // Test 2: Override parameters
        if (pm_override.WIDTH == 16 && pm_override.DEPTH == 32) begin
            $display("PASS: Test 2 - Override parameters (%0d, %0d)", pm_override.WIDTH, pm_override.DEPTH);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Override parameters incorrect (%0d, %0d)", pm_override.WIDTH, pm_override.DEPTH);
            fail_count++;
        end

        // Test 3: localparam
        if (lpm.LOCAL_VAL == 42 && lpm.DERIVED == 84) begin
            $display("PASS: Test 3 - localparam values (%0d, %0d)", lpm.LOCAL_VAL, lpm.DERIVED);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - localparam values incorrect (%0d, %0d)", lpm.LOCAL_VAL, lpm.DERIVED);
            fail_count++;
        end

        // Test 4: Type parameter (check data width)
        if (tpm.data_width == 16) begin
            $display("PASS: Test 4 - Type parameter width = %0d", tpm.data_width);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Type parameter width incorrect = %0d", tpm.data_width);
            fail_count++;
        end

        // Test 5: Multiple parameters
        if (mpm.A == 100 && mpm.B == 200 && mpm.C == 8'hFF) begin
            $display("PASS: Test 5 - Multiple parameters (%0d, %0d, %h)", mpm.A, mpm.B, mpm.C);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Multiple parameters incorrect");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

module param_module_default #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
);
endmodule

module param_module #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
);
    logic [WIDTH-1:0] data [DEPTH-1:0];
endmodule

module localparam_module;
    localparam LOCAL_VAL = 42;
    localparam DERIVED = LOCAL_VAL * 2;
endmodule

module type_param_module #(
    parameter type T = logic [7:0]
);
    T data;
    localparam data_width = $bits(T);
endmodule

module multi_param_module #(
    parameter A = 1,
    parameter B = 2,
    parameter logic [7:0] C = 8'h00
);
endmodule
