/*
:name: test_cast_ext
:description: Test 1: int to shortint
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1 11.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_ext.expected
*/
// IEEE 1800-2023 §6.24

module test_cast_ext;
    int ival;
    shortint sival;
    longint lival;
    byte bval;
    real rval;
    logic [31:0] lval;
    logic signed [31:0] slval;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: int to shortint
        test_count++;
        ival = 32'h12345678;
        sival = shortint'(ival);
        if (sival == 16'h5678) begin
            $display("Test 1: int to shortint PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL sival=%h", sival);
        end

        // Test 2: int to byte
        test_count++;
        bval = byte'(ival);
        if (bval == 8'h78) begin
            $display("Test 2: int to byte PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL bval=%h", bval);
        end

        // Test 3: int to longint
        test_count++;
        ival = -1;
        lival = longint'(ival);
        if (lival == -1) begin
            $display("Test 3: int to longint PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL lival=%0d", lival);
        end

        // Test 4: real to int rounding
        test_count++;
        rval = 3.9;
        ival = int'(rval);
        $display("Test 4: real to int PASS ival=%0d", ival);
        pass_count++;

        // Test 5: Negative real to int
        test_count++;
        rval = -2.5;
        ival = int'(rval);
        $display("Test 5: neg real PASS ival=%0d", ival);
        pass_count++;

        // Test 6: unsigned to signed
        test_count++;
        lval = 32'h80000000;
        slval = $signed(lval);
        if (slval < 0) begin
            $display("Test 6: unsigned to signed PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL slval=%0d", slval);
        end

        // Test 7: signed to unsigned
        test_count++;
        slval = -100;
        lval = $unsigned(slval);
        if (lval > 0) begin
            $display("Test 7: signed to unsigned PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL lval=%0d", lval);
        end

        // Test 8: Cast in expression
        test_count++;
        ival = int'(3.5) + int'(2.5);
        $display("Test 8: cast in expr PASS ival=%0d", ival);
        pass_count++;

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
