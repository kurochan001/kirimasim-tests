/*
:name: test_expr_bitsel
:description: Test for bit select and part select
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_bitsel.expected
*/
// Test for bit select and part select
// IEEE 1800-2023 §11.5: Bit-select and part-select
module test_expr_bitsel;
    initial begin
        static logic [31:0] data = 32'hDEADBEEF;
        logic [7:0] byte_sel;
        logic single;

        // Bit select
        single = data[0];
        if (single != 1'b1) $display("FAIL: Bit select");

        // Part select
        byte_sel = data[7:0];
        if (byte_sel != 8'hEF) $display("FAIL: Part select");

        // Indexed part select +
        byte_sel = data[8 +: 8];
        if (byte_sel != 8'hBE) $display("FAIL: Indexed part +");

        // Indexed part select -
        byte_sel = data[23 -: 8];
        if (byte_sel != 8'hAD) $display("FAIL: Indexed part -");

        $display("PASS: Bit select expression");
        $finish;
    end
endmodule
