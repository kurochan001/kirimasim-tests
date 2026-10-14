/*
:name: test_assign_increment
:description: Increment/decrement
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_increment.expected
*/
// IEEE 1800-2023 §10.4: Increment/decrement
module test_assign_increment;
    int pass_count = 0;
    int fail_count = 0;
    int a;

    initial begin
        // Test 1: Post-increment
        a = 10;
        a++;
        if (a == 11) begin
            $display("Test 1 PASS: post++ = %0d", a);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", a);
            fail_count++;
        end

        // Test 2: Post-decrement
        a = 10;
        a--;
        if (a == 9) begin
            $display("Test 2 PASS: post-- = %0d", a);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", a);
            fail_count++;
        end

        // Test 3: Pre-increment
        a = 5;
        ++a;
        if (a == 6) begin
            $display("Test 3 PASS: ++pre = %0d", a);
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
