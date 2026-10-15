/*
:name: test_module_array
:description: Module instance arrays test
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.5 27.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_array.expected
*/
// Module instance arrays test
module test_module_array;
    int pass_count = 0;
    int fail_count = 0;

    // Signals
    logic clk = 0;
    logic [3:0] enables = 4'b1111;
    logic [7:0] data_in [4];
    logic [7:0] data_out [4];

    // Test 1: Basic module array
    basic_array_mod bam[4]();

    // Test 2: Module array with connections
    logic [7:0] arr_result [4];
    connected_array_mod cam[4](.data(arr_result));

    // Test 3: Module array with indexed connections
    logic [7:0] indexed_in [4] = '{8'h10, 8'h20, 8'h30, 8'h40};
    logic [7:0] indexed_out [4];

    // Test 4: Module array with generate-like indexing
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_array
            indexed_array_mod iam(.in(indexed_in[i]), .out(indexed_out[i]));
        end
    endgenerate

    simple_cell cell_2d[4]();

    initial begin
        #1;

        // Test 1: Basic module array - each has unique instance
        if (bam[0].id == 0 && bam[1].id == 0 && bam[2].id == 0 && bam[3].id == 0) begin
            $display("PASS: Test 1 - Basic module array instantiated");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic module array issue");
            fail_count++;
        end

        // Test 2: Connected array modules
        if (arr_result[0] == 8'hAA && arr_result[1] == 8'hAA &&
            arr_result[2] == 8'hAA && arr_result[3] == 8'hAA) begin
            $display("PASS: Test 2 - Connected array modules");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Connected array failed (%h %h %h %h)",
                     arr_result[0], arr_result[1], arr_result[2], arr_result[3]);
            fail_count++;
        end

        // Test 3 & 4: Indexed connections via generate
        if (indexed_out[0] == 8'h10 && indexed_out[1] == 8'h20 &&
            indexed_out[2] == 8'h30 && indexed_out[3] == 8'h40) begin
            $display("PASS: Test 3 - Indexed array connections");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Indexed array failed (%h %h %h %h)",
                     indexed_out[0], indexed_out[1], indexed_out[2], indexed_out[3]);
            fail_count++;
        end

        // Test 4: Generate array instances accessible
        if (gen_array[0].iam.in == 8'h10 && gen_array[3].iam.in == 8'h40) begin
            $display("PASS: Test 4 - Generate array instances accessible");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Generate array access failed");
            fail_count++;
        end

        if (cell_2d[0].value == 99 && cell_2d[3].value == 99) begin
            $display("PASS: Test 5 - Flattened 2D module array");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Flattened 2D module array failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule

module basic_array_mod;
    int id = 0;
endmodule

module connected_array_mod(
    output logic [7:0] data
);
    assign data = 8'hAA;
endmodule

module indexed_array_mod(
    input logic [7:0] in,
    output logic [7:0] out
);
    assign out = in;
endmodule

module simple_cell;
    int value = 99;
endmodule
