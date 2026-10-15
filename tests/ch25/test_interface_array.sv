/*
:name: test_interface_array
:description: Interface arrays test
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_array.expected
*/
// Interface arrays test
module test_interface_array;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic interface array
    simple_if sif[4]();

    // Test 2: Interface array with generate
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_if
            gen_if_inst gii();
        end
    endgenerate

    // Test 3: Module using interface array
    data_if dif[2]();
    if_array_user iau(.dif_arr(dif));

    // Test 4: 2D interface array
    matrix_if mif[2][2]();

    // Test 5: Parameterized interface array
    param_array_if #(.WIDTH(16)) paif[3]();

    initial begin
        #1;

        // Test 1: Basic interface array - each instance independent
        sif[0].data = 8'h11;
        sif[1].data = 8'h22;
        sif[2].data = 8'h33;
        sif[3].data = 8'h44;
        if (sif[0].data == 8'h11 && sif[1].data == 8'h22 &&
            sif[2].data == 8'h33 && sif[3].data == 8'h44) begin
            $display("PASS: Test 1 - Basic interface array independent");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic interface array failed");
            fail_count++;
        end

        // Test 2: Generated interface instances
        gen_if[0].gii.value = 100;
        gen_if[1].gii.value = 200;
        gen_if[2].gii.value = 300;
        gen_if[3].gii.value = 400;
        if (gen_if[0].gii.value == 100 && gen_if[3].gii.value == 400) begin
            $display("PASS: Test 2 - Generated interface array");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Generated interface array failed");
            fail_count++;
        end

        // Test 3: Module using interface array
        dif[0].data = 32'hAAAA;
        dif[1].data = 32'hBBBB;
        #1;
        if (iau.sum == 32'hAAAA + 32'hBBBB) begin
            $display("PASS: Test 3 - Module using interface array");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Module interface array failed (sum=%h)", iau.sum);
            fail_count++;
        end

        // Test 4: 2D interface array
        mif[0][0].cell_data = 8'h00;
        mif[0][1].cell_data = 8'h01;
        mif[1][0].cell_data = 8'h10;
        mif[1][1].cell_data = 8'h11;
        if (mif[0][0].cell_data == 8'h00 && mif[1][1].cell_data == 8'h11) begin
            $display("PASS: Test 4 - 2D interface array");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - 2D interface array failed");
            fail_count++;
        end

        // Test 5: Parameterized interface array
        paif[0].wide_data = 16'h1111;
        paif[1].wide_data = 16'h2222;
        paif[2].wide_data = 16'h3333;
        if (paif[0].wide_data == 16'h1111 && paif[2].wide_data == 16'h3333) begin
            $display("PASS: Test 5 - Parameterized interface array");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Parameterized interface array failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

interface simple_if;
    logic [7:0] data;
    logic valid;
endinterface

interface gen_if_inst;
    int value;
endinterface

interface data_if;
    logic [31:0] data;
    logic valid;
endinterface

module if_array_user(
    data_if dif_arr[2]
);
    logic [31:0] sum;
    always @(*) begin
        sum = dif_arr[0].data + dif_arr[1].data;
    end
endmodule

interface matrix_if;
    logic [7:0] cell_data;
endinterface

interface param_array_if #(
    parameter WIDTH = 8
);
    logic [WIDTH-1:0] wide_data;
endinterface
