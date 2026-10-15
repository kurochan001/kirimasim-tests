/*
:name: test_system_isunknown
:description: $isunknown - check for X or Z bits
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_system_isunknown.expected
*/
// $isunknown - check for X or Z bits
module test_isunknown;
    logic [7:0] val8;
    logic [3:0] val4;
    int result;

    initial begin
        // Test 1: All known values (no X or Z)
        val8 = 8'b10101010;
        result = $isunknown(val8);
        if (result == 0)
            $display("PASS: $isunknown(8'b10101010) = %0d (no unknowns)", result);
        else
            $display("FAIL: $isunknown(8'b10101010) = %0d, expected 0", result);

        // Test 2: Contains X bit
        val8 = 8'b1010x010;
        result = $isunknown(val8);
        if (result == 1)
            $display("PASS: $isunknown(8'b1010x010) = %0d (has X)", result);
        else
            $display("FAIL: $isunknown(8'b1010x010) = %0d, expected 1", result);

        // Test 3: Contains Z bit
        val8 = 8'b1010z010;
        result = $isunknown(val8);
        if (result == 1)
            $display("PASS: $isunknown(8'b1010z010) = %0d (has Z)", result);
        else
            $display("FAIL: $isunknown(8'b1010z010) = %0d, expected 1", result);

        // Test 4: All X
        val4 = 4'bxxxx;
        result = $isunknown(val4);
        if (result == 1)
            $display("PASS: $isunknown(4'bxxxx) = %0d (all X)", result);
        else
            $display("FAIL: $isunknown(4'bxxxx) = %0d, expected 1", result);

        // Test 5: All zeros
        val8 = 8'b00000000;
        result = $isunknown(val8);
        if (result == 0)
            $display("PASS: $isunknown(8'b00000000) = %0d (all zeros)", result);
        else
            $display("FAIL: $isunknown(8'b00000000) = %0d, expected 0", result);

        $finish;
    end
endmodule
