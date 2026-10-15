/*
:name: test_assign_force_release
:description: Test for force/release
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_force_release.expected
*/
// Test for force/release
// IEEE 1800-2023 §10.6: Force and release
module test_assign_force_release;
    logic clk = 0;
    logic [7:0] data;
    wire [7:0] wire_data;

    assign wire_data = data;

    always #5 clk = ~clk;

    initial begin
        data = 8'h00;
        #1;
        if (wire_data != 8'h00) $display("FAIL: Initial");

        // Force value
        force wire_data = 8'hFF;
        data = 8'hAA;
        #1;
        if (wire_data != 8'hFF) $display("FAIL: Force %h", wire_data);

        // Release
        release wire_data;
        #1;
        if (wire_data != 8'hAA) $display("FAIL: Release %h", wire_data);

        // Force register
        force data = 8'h55;
        #1;
        if (data != 8'h55) $display("FAIL: Force reg %h", data);

        release data;
        data = 8'hBB;
        #1;
        if (data != 8'hBB) $display("FAIL: Release reg %h", data);

        $display("PASS: Force/release");
        $finish;
    end
endmodule
