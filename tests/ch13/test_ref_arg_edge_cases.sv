/*
:name: test_ref_arg_edge_cases
:description: Reference argument edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_arg_edge_cases.expected
*/
// IEEE 1800-2023 §13.5: Reference argument edge cases
// Tests for ref arguments

module test_ref_arg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function automatic void swap(ref int a, ref int b);
        int temp = a;
        a = b;
        b = temp;
    endfunction

    function automatic void increment_ref(ref int x);
        x++;
    endfunction

    function automatic void double_val(ref int x);
        x = x * 2;
    endfunction

    function automatic int modify_and_return(ref int x);
        x = x + 10;
        return x;
    endfunction

    function automatic void triple_val(ref int x);
        x = x * 3;
    endfunction

    initial begin
        int a, b, c;

        // Test 1: Swap values
        test_count++;
        a = 10;
        b = 20;
        swap(a, b);
        if (a == 20 && b == 10) begin
            pass_count++;
            $display("Test 1 PASS: Swap a=%0d b=%0d", a, b);
        end else begin
            $display("Test 1 FAIL: Swap unexpected a=%0d b=%0d", a, b);
        end

        // Test 2: Increment by ref
        test_count++;
        c = 5;
        increment_ref(c);
        if (c == 6) begin
            pass_count++;
            $display("Test 2 PASS: Inc ref = %0d", c);
        end else begin
            $display("Test 2 FAIL: Inc unexpected = %0d", c);
        end

        // Test 3: Double value
        test_count++;
        c = 7;
        double_val(c);
        if (c == 14) begin
            pass_count++;
            $display("Test 3 PASS: Double = %0d", c);
        end else begin
            $display("Test 3 FAIL: Double unexpected = %0d", c);
        end

        // Test 4: Modify and return
        test_count++;
        c = 5;
        begin
            static int ret;
            // Assigned here so the result does not depend on the order of static initializers.
            ret = modify_and_return(c);
            if (c == 15 && ret == 15) begin
                pass_count++;
                $display("Test 4 PASS: Mod+ret c=%0d ret=%0d", c, ret);
            end else begin
                $display("Test 4 FAIL: Mod+ret unexpected");
            end
        end

        // Test 5: Multiple increments
        test_count++;
        c = 0;
        for (int i = 0; i < 5; i++)
            increment_ref(c);
        if (c == 5) begin
            pass_count++;
            $display("Test 5 PASS: Multi inc = %0d", c);
        end else begin
            $display("Test 5 FAIL: Multi unexpected = %0d", c);
        end

        // Test 6: Triple value
        test_count++;
        c = 4;
        triple_val(c);
        if (c == 12) begin
            pass_count++;
            $display("Test 6 PASS: Triple = %0d", c);
        end else begin
            $display("Test 6 FAIL: Triple unexpected = %0d", c);
        end

        // Test 7: Chain of modifications
        test_count++;
        c = 1;
        double_val(c);
        double_val(c);
        double_val(c);
        if (c == 8) begin
            pass_count++;
            $display("Test 7 PASS: Chain = %0d", c);
        end else begin
            $display("Test 7 FAIL: Chain unexpected = %0d", c);
        end

        // Test 8: Swap same values
        test_count++;
        a = 42;
        b = 42;
        swap(a, b);
        if (a == 42 && b == 42) begin
            pass_count++;
            $display("Test 8 PASS: Same swap a=%0d", a);
        end else begin
            $display("Test 8 FAIL: Same unexpected");
        end

        // Test 9: Zero value
        test_count++;
        c = 0;
        increment_ref(c);
        if (c == 1) begin
            pass_count++;
            $display("Test 9 PASS: Zero inc = %0d", c);
        end else begin
            $display("Test 9 FAIL: Zero unexpected = %0d", c);
        end

        // Test 10: Negative value
        test_count++;
        c = -5;
        double_val(c);
        if (c == -10) begin
            pass_count++;
            $display("Test 10 PASS: Neg double = %0d", c);
        end else begin
            $display("Test 10 FAIL: Neg unexpected = %0d", c);
        end

        $display("=== Ref Arg Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
