/*
:name: test_interface_param
:description: Parameterized interface test
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.8 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_param.expected
*/
// Parameterized interface test
module test_interface_param;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Interface with default parameters
    param_if_default pif_def();

    // Test 2: Interface with overridden parameters
    param_if #(.WIDTH(16), .DEPTH(32)) pif_override();

    // Test 3: Interface with type parameter
    type_param_if #(.T(logic [31:0])) tpif();

    // Test 4: Interface with multiple parameters
    multi_param_if #(.ADDR_WIDTH(16), .DATA_WIDTH(32), .ID_WIDTH(4)) mpif();

    // Test 5: Module using parameterized interface
    param_if #(.WIDTH(8)) pif_mod();
    param_if_user #(.WIDTH(8)) piu(.pif(pif_mod));

    initial begin
        #1;

        // Test 1: Default parameters
        if (pif_def.WIDTH == 8 && pif_def.DEPTH == 16) begin
            $display("PASS: Test 1 - Default parameters (WIDTH=%0d, DEPTH=%0d)",
                     pif_def.WIDTH, pif_def.DEPTH);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Default parameters incorrect");
            fail_count++;
        end

        // Test 2: Overridden parameters
        if (pif_override.WIDTH == 16 && pif_override.DEPTH == 32) begin
            $display("PASS: Test 2 - Override parameters (WIDTH=%0d, DEPTH=%0d)",
                     pif_override.WIDTH, pif_override.DEPTH);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Override parameters incorrect");
            fail_count++;
        end

        // Test 3: Type parameter
        tpif.data = 32'hCAFEBABE;
        if (tpif.data == 32'hCAFEBABE && $bits(tpif.data) == 32) begin
            $display("PASS: Test 3 - Type parameter (data=%h, bits=%0d)",
                     tpif.data, $bits(tpif.data));
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Type parameter incorrect");
            fail_count++;
        end

        // Test 4: Multiple parameters
        if (mpif.ADDR_WIDTH == 16 && mpif.DATA_WIDTH == 32 && mpif.ID_WIDTH == 4) begin
            $display("PASS: Test 4 - Multiple parameters (ADDR=%0d, DATA=%0d, ID=%0d)",
                     mpif.ADDR_WIDTH, mpif.DATA_WIDTH, mpif.ID_WIDTH);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Multiple parameters incorrect");
            fail_count++;
        end

        // Test 5: Module using parameterized interface
        pif_mod.data = 8'hAB;
        #1;
        if (piu.captured_data == 8'hAB) begin
            $display("PASS: Test 5 - Module using parameterized interface");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Module interface usage failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

interface param_if_default #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
);
    logic [WIDTH-1:0] data;
    logic [DEPTH-1:0] addr;
endinterface

interface param_if #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
);
    logic [WIDTH-1:0] data;
    logic [$clog2(DEPTH)-1:0] addr;

    modport master(input data, input addr);
endinterface

interface type_param_if #(
    parameter type T = logic [7:0]
);
    T data;
    logic valid;
endinterface

interface multi_param_if #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter ID_WIDTH = 2
);
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] data;
    logic [ID_WIDTH-1:0] id;
endinterface

module param_if_user #(
    parameter WIDTH = 8
)(
    param_if.master pif
);
    logic [WIDTH-1:0] captured_data;

    always @(*) begin
        captured_data = pif.data;
    end
endmodule
