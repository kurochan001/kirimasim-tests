/*
:name: test_assign_compound
:description: Compound assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 11.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_compound.expected
*/
// IEEE 1800-2023 §10.4: Compound assignments
module test_assign_compound;
    int pass_count = 0;
    int fail_count = 0;
    int a;

    initial begin
        // Test 1: += operator
        a = 10;
        a += 5;
        if (a == 15) begin
            $display("Test 1 PASS: += result = %0d", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", a);
            fail_count++;
        end

        // Test 2: += with larger value
        a = 100;
        a += 50;
        if (a == 150) begin
            $display("Test 2 PASS: += large = %0d", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", a);
            fail_count++;
        end

        // Test 3: += with zero
        a = 42;
        a += 0;
        if (a == 42) begin
            $display("Test 3 PASS: += 0 = %0d", a);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", a);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
