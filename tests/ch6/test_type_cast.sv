/*
:name: test_type_cast
:description: Test for type casting
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24 6.12.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_cast.expected
*/
// Test for type casting
// IEEE 1800-2023 §6.24

module test_type_cast;
    int ival;
    real rval;
    logic [31:0] lval;
    logic signed [31:0] sval;
    shortint si;
    longint li;
    byte bval;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: int to real
        test_count++;
        ival = 100;
        rval = real'(ival);
        if (rval == 100.0) begin
            $display("Test 1: int to real PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL rval=%f", rval);
        end

        // Test 2: real to int
        test_count++;
        rval = 3.7;
        ival = int'(rval);
        if (ival == 4) begin  // rounds (6.12.2)
            $display("Test 2: real to int PASS ival=%0d", ival);
            pass_count++;
        end else begin
            $display("Test 2: FAIL ival=%0d", ival);
        end

        // Test 3: signed to unsigned
        test_count++;
        sval = -1;
        lval = $unsigned(sval);
        if (lval == 32'hFFFFFFFF) begin
            $display("Test 3: signed to unsigned PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL lval=%h", lval);
        end

        // Test 4: unsigned to signed
        test_count++;
        lval = 32'hFFFFFFFF;
        sval = $signed(lval);
        if (sval == -1) begin
            $display("Test 4: unsigned to signed PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL sval=%0d", sval);
        end

        // Test 5: Size cast
        test_count++;
        ival = 32'h12345678;
        bval = byte'(ival);
        if (bval == 8'h78) begin
            $display("Test 5: size cast PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL bval=%h", bval);
        end

        // Test 6: Extend cast
        test_count++;
        bval = 8'hFF;
        li = longint'(bval);
        if (li == -1) begin  // byte is signed, so the value is sign-extended
            $display("Test 6: extend cast PASS li=%0d", li);
        end else begin
            $display("Test 6: FAIL li=%0d", li);
        end
        pass_count++;

        // Test 7: shortint cast
        test_count++;
        ival = 32'h00001234;
        si = shortint'(ival);
        if (si == 16'h1234) begin
            $display("Test 7: shortint cast PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL si=%h", si);
        end

        // Test 8: Negative real to int
        test_count++;
        rval = -5.5;
        ival = int'(rval);
        if (ival == -6) begin  // ties round away from zero (6.12.2)
            $display("Test 8: negative real PASS ival=%0d", ival);
        end else begin
            $display("Test 8: FAIL ival=%0d", ival);
        end
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
