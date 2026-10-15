/*
:name: test_assert_immed
:description: Immediate assertions
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_immed.expected
*/
// IEEE 1800-2023 Section 16.3: Immediate assertions
module test_assert_immed;
    int a, b;
    int pass_count;

    initial begin
        pass_count = 0;
        a = 10;
        b = 10;

        // Simple assert pass
        assert (a == b) pass_count = pass_count + 1;
        if (pass_count == 1)
            $display("PASS: assert pass");
        else
            $display("FAIL: pass = %0d", pass_count);

        // Assert with else
        a = 5;
        assert (a == b)
            pass_count = pass_count + 10;
        else
            pass_count = pass_count + 1;
        if (pass_count == 2)
            $display("PASS: assert else");
        else
            $display("FAIL: else = %0d", pass_count);

        // Assert with message
        a = 10;
        assert (a > 0) $display("PASS: assert message");
        else $display("FAIL: message");

        // Additional assert
        a = 10;
        b = 10;
        assert (a == b) pass_count = pass_count + 1;
        if (pass_count == 3)
            $display("PASS: assert equal");
        else
            $display("FAIL: equal = %0d", pass_count);

        $display("TEST PASSED: immediate assertion tests completed");
        $finish;
    end
endmodule
