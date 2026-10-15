/*
:name: test_cast_longint
:description: Longint type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_longint.expected
*/
// IEEE 1800-2023 §6.24: Longint type casts
module test_cast_longint;
    int pass_count = 0;
    int fail_count = 0;
    longint lival;
    int ival;

    initial begin
        // Test 1: Int to longint
        ival = 1000000;
        lival = longint'(ival);
        if (lival == 1000000) begin
            $display("Test 1 PASS: int to longint = %0d", lival);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", lival);
            fail_count++;
        end

        // Test 2: Negative
        ival = -1000000;
        lival = longint'(ival);
        if (lival == -1000000) begin
            $display("Test 2 PASS: negative = %0d", lival);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", lival);
            fail_count++;
        end

        // Test 3: Large value
        lival = 64'h123456789ABCDEF0;
        if (lival == 64'h123456789ABCDEF0) begin
            $display("Test 3 PASS: large value = %016h", lival);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %016h", lival);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
