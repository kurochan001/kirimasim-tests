/*
:name: test_system_isunbounded
:description: Test $isunbounded - unbounded parameter check
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.3 6.20.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_isunbounded.expected
*/
// Test $isunbounded - unbounded parameter check
module test_system_isunbounded;
    // Parameters with default values
    parameter int BOUNDED_PARAM = 10;
    parameter int UNBOUNDED_PARAM = $;

    // Test with different parameter types
    parameter real REAL_PARAM = 3.14;
    parameter string STRING_PARAM = "test";

    int result;

    initial begin
        // Test 1: Bounded integer parameter
        result = $isunbounded(BOUNDED_PARAM);
        if (result == 0)
            $display("PASS: $isunbounded(BOUNDED_PARAM) = %0d (bounded)", result);
        else
            $display("FAIL: $isunbounded(BOUNDED_PARAM) = %0d, expected 0", result);

        // Test 2: Unbounded parameter ($)
        result = $isunbounded(UNBOUNDED_PARAM);
        if (result == 1)
            $display("PASS: $isunbounded(UNBOUNDED_PARAM) = %0d (unbounded)", result);
        else
            $display("FAIL: $isunbounded(UNBOUNDED_PARAM) = %0d, expected 1", result);

        // Test 3: Real parameter (bounded)
        result = $isunbounded(REAL_PARAM);
        if (result == 0)
            $display("PASS: $isunbounded(REAL_PARAM) = %0d (bounded)", result);
        else
            $display("FAIL: $isunbounded(REAL_PARAM) = %0d, expected 0", result);

        // Test 4: Literal value
        result = $isunbounded(100);
        if (result == 0)
            $display("PASS: $isunbounded(100) = %0d (literal is bounded)", result);
        else
            $display("FAIL: $isunbounded(100) = %0d, expected 0", result);

        // Test 5: String parameter (bounded)
        result = $isunbounded(STRING_PARAM);
        if (result == 0)
            $display("PASS: $isunbounded(STRING_PARAM) = %0d (bounded)", result);
        else
            $display("FAIL: $isunbounded(STRING_PARAM) = %0d, expected 0", result);

        $finish;
    end
endmodule
