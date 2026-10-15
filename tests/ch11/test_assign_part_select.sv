/*
:name: test_assign_part_select
:description: Test for part-select assignment
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 10.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_part_select.expected
*/
// Test for part-select assignment
// IEEE 1800-2023 §11.5: Bit-select and part-select
module test_assign_part_select;
    initial begin
        static logic [31:0] data = 32'h12345678;
        logic [7:0] byte_val;
        int idx;

        // Bit assignment
        data[0] = 1'b0;
        if (data != 32'h12345678) $display("FAIL: Bit assign");

        // Part-select assignment
        data[7:0] = 8'hFF;
        if (data != 32'h123456FF) $display("FAIL: Part-select assign %h", data);

        // Indexed part-select +
        data[15:8] = 8'hAA;
        if (data != 32'h1234AAFF) $display("FAIL: Indexed + assign %h", data);

        // Variable indexed part-select
        idx = 16;
        data[idx +: 8] = 8'h00;
        if (data != 32'h1200AAFF) $display("FAIL: Variable indexed %h", data);

        // Indexed part-select -
        data[31 -: 8] = 8'hBB;
        if (data != 32'hBB00AAFF) $display("FAIL: Indexed - assign %h", data);

        $display("PASS: Part-select assignment");
        $finish;
    end
endmodule
