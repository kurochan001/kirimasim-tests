/*
:name: test_sysfunc_ext
:description: Test 1: $ln
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_ext.expected
*/
// IEEE 1800-2023 §20.8.2

module test_sysfunc_ext;
    int val;
    real rval;
    logic [31:0] lval;
    string str;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $ln
        test_count++;
        rval = $ln(2.718281828);
        $display("Test 1: $ln(e)=%f PASS", rval);
        pass_count++;

        // Test 2: $log10
        test_count++;
        rval = $log10(100);
        $display("Test 2: $log10=%f PASS", rval);
        pass_count++;

        // Test 3: $exp
        test_count++;
        rval = $exp(1.0);
        $display("Test 3: $exp=%f PASS", rval);
        pass_count++;

        // Test 4: $sqrt
        test_count++;
        rval = $sqrt(16.0);
        if (rval == 4.0) begin
            $display("Test 4: $sqrt PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL rval=%f", rval);
        end

        // Test 5: $pow
        test_count++;
        rval = $pow(2.0, 10.0);
        if (rval > 1024.0 - 1e-9 && rval < 1024.0 + 1e-9) begin
            $display("Test 5: $pow PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL rval=%f", rval);
        end

        // Test 6: $floor
        test_count++;
        rval = $floor(3.7);
        if (rval == 3.0) begin
            $display("Test 6: $floor PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL rval=%f", rval);
        end

        // Test 7: $ceil
        test_count++;
        rval = $ceil(3.2);
        if (rval == 4.0) begin
            $display("Test 7: $ceil PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL rval=%f", rval);
        end

        // Test 8: $sin
        test_count++;
        rval = $sin(0.0);
        if (rval > 0.0 - 1e-9 && rval < 0.0 + 1e-9) begin
            $display("Test 8: $sin(0) PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL rval=%f", rval);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
