/*
:name: test_isunknown
:description: Unknown detection
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_isunknown.expected
*/
// IEEE 1800-2023 Section 20.9: Unknown detection
module test_isunknown;
    logic [7:0] val;
    int result;

    initial begin
        // $isunknown - no X or Z
        val = 8'b1010_1010;
        result = $isunknown(val);
        if (result == 0)
            $display("PASS: $isunknown no x");
        else
            $display("FAIL: isunknown = %0d", result);

        // $isunknown with X
        val = 8'b1010_x010;
        result = $isunknown(val);
        if (result == 1)
            $display("PASS: $isunknown with x");
        else
            $display("FAIL: isunknown x = %0d", result);

        // $isunknown with Z
        val = 8'b1010_z010;
        result = $isunknown(val);
        if (result == 1)
            $display("PASS: $isunknown with z");
        else
            $display("FAIL: isunknown z = %0d", result);

        $display("TEST PASSED: isunknown tests completed");
        $finish;
    end
endmodule
