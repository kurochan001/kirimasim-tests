/*
:name: test_assign_partselect
:description: Part-select assignments
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_partselect.expected
*/
// IEEE 1800-2023 §10.4: Part-select assignments
module test_assign_partselect;
    int pass_count = 0;
    int fail_count = 0;
    logic [15:0] val;

    initial begin
        // Test 1: Upper byte assign
        val = 16'h0000;
        val[15:8] = 8'hAB;
        if (val == 16'hAB00) begin
            $display("Test 1 PASS: upper byte = %04h", val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %04h", val);
            fail_count++;
        end

        // Test 2: Lower byte assign
        val[7:0] = 8'hCD;
        if (val == 16'hABCD) begin
            $display("Test 2 PASS: lower byte = %04h", val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %04h", val);
            fail_count++;
        end

        // Test 3: Single bit assign
        val = 16'h0000;
        val[8] = 1'b1;
        if (val == 16'h0100) begin
            $display("Test 3 PASS: single bit = %04h", val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %04h", val);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
