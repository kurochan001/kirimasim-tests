/*
:name: test_valueops_compare
:description: Equality, inequality and less-than on int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4 11.4.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_valueops_compare.expected
*/
// IEEE 1800-2023 §11.4: Comparison operations
module test_valueops_compare;
    int pass_count = 0;
    int fail_count = 0;
    int a, b;

    initial begin
        // Test 1: Equal
        a = 10;
        b = 10;
        if (a == b) begin
            $display("Test 1 PASS: equal");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Not equal
        a = 5;
        b = 10;
        if (a != b) begin
            $display("Test 2 PASS: not equal");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Less than
        a = 5;
        b = 10;
        if (a < b) begin
            $display("Test 3 PASS: less than");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
