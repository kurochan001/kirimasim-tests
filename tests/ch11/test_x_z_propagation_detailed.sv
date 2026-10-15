/*
:name: test_x_z_propagation_detailed
:description: Corner Case: X/Z Propagation Detailed
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8 11.4.5 11.4.3 12.4 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_x_z_propagation_detailed.expected
*/
// Corner Case: X/Z Propagation Detailed
// Tests unknown (X) and high-impedance (Z) value propagation

module test_x_z_propagation_detailed;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] a, b, result;
    logic single;

    initial begin
        // Test 1: Basic X assignment
        a = 8'bxxxxxxxx;
        if ($isunknown(a)) pass_count++;
        else begin fail_count++; $display("FAIL: basic X"); end

        // Test 2: Basic Z assignment
        b = 8'bzzzzzzzz;
        if ($isunknown(b)) pass_count++;
        else begin fail_count++; $display("FAIL: basic Z"); end

        // Test 3: X in bitwise AND (X & 0 = 0)
        a = 8'bxxxxxxxx;
        b = 8'h00;
        result = a & b;
        if (result == 8'h00) pass_count++;
        else begin fail_count++; $display("FAIL: X AND 0"); end

        // Test 4: X in bitwise OR (X | 1 = 1)
        a = 8'bxxxxxxxx;
        b = 8'hFF;
        result = a | b;
        if (result == 8'hFF) pass_count++;
        else begin fail_count++; $display("FAIL: X OR 1"); end

        // Test 5: Partial X bits
        a = 8'b1111xxxx;
        if (a[7:4] == 4'b1111) pass_count++;
        else begin fail_count++; $display("FAIL: partial X high bits"); end

        // Test 6: Case equality with X
        a = 8'bxxxxxxxx;
        b = 8'bxxxxxxxx;
        if (a === b) pass_count++;
        else begin fail_count++; $display("FAIL: case equality X"); end

        // Test 7: Case inequality X vs value
        a = 8'bxxxxxxxx;
        b = 8'h00;
        if (a !== b) pass_count++;
        else begin fail_count++; $display("FAIL: case inequality X"); end

        // Test 8: Z propagation through assignment
        a = 8'bzzzzzzzz;
        result = a;
        if (result === 8'bzzzzzzzz) pass_count++;
        else begin fail_count++; $display("FAIL: Z propagation"); end

        // Test 9: Mixed X and known bits
        a = 8'b10101010;
        a[3:0] = 4'bxxxx;
        if (a[7:4] == 4'b1010 && $isunknown(a[3:0])) pass_count++;
        else begin fail_count++; $display("FAIL: mixed X known"); end

        // Test 10: Single bit X
        single = 1'bx;
        if ($isunknown(single)) pass_count++;
        else begin fail_count++; $display("FAIL: single bit X"); end

        // Test 11: Z converts to X in some operations
        a = 8'bzzzzzzzz;
        result = a + 1;
        if ($isunknown(result)) pass_count++;
        else begin fail_count++; $display("FAIL: Z in arithmetic"); end

        // Test 12: X in comparison returns X
        a = 8'bxxxxxxxx;
        b = 8'h55;
        // Regular equality with X gives X result, treated as false in if
        if (a == b)
            begin fail_count++; $display("FAIL: X equality should be false"); end
        else
            pass_count++;

        if (fail_count == 0)
            $display("TEST PASSED (%0d/12)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
