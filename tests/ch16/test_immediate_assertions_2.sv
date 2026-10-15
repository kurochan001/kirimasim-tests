/*
:name: test_immediate_assertions_2
:description: Immediate Assertions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertions_2.expected
*/
// IEEE 1800-2023 §16.3 Immediate Assertions
// Tests assert, assume, cover immediate assertions

module test_immediate_assertions;
    int pass_count = 0;
    int fail_count = 0;
    int x, y;

    initial begin
        // Test 1: Simple passing assert
        x = 5;
        assert (x == 5) begin
            $display("PASS: Simple assert passed");
            pass_count++;
        end else begin
            $display("FAIL: Simple assert should have passed");
            fail_count++;
        end

        // Test 2: Assert with message on pass
        y = 10;
        assert (y > 0) $display("PASS: Assert with condition y > 0");
        pass_count++;

        // Test 3: Deferred assert (should pass)
        x = 100;
        assert #0 (x == 100);
        $display("PASS: Deferred assert passed");
        pass_count++;

        // Test 4: Assert with else action (test the else path)
        x = 0;
        assert (x != 0) begin
            $display("FAIL: This should not print");
            fail_count++;
        end else begin
            $display("PASS: Assert else clause executed");
            pass_count++;
        end

        // Test 5: Assert with complex expression
        x = 15;
        y = 3;
        assert (x / y == 5 && x % y == 0) begin
            $display("PASS: Complex assert expression");
            pass_count++;
        end else begin
            $display("FAIL: Complex assert failed");
            fail_count++;
        end

        // Test 6: Cover statement. Its pass statement runs when the expression
        // is true (16.3).
        x = 42;
        cover (x == 42) begin
            $display("PASS: Cover hit for x == 42");
            pass_count++;
        end

        // Test 7: Multiple sequential asserts
        for (int i = 1; i <= 3; i++) begin
            assert (i > 0) else $fatal(1, "i must be positive");
        end
        $display("PASS: Multiple sequential asserts");
        pass_count++;

        $display("");
        $display("=== Immediate Assertions Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0 && pass_count == 7)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
