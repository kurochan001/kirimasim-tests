/*
:name: test_while_return_automatic
:description: automatic function creates new scope for each call
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2 13.4.4 12.7.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_while_return_automatic.expected
*/
module test_while_return_automatic;
    // IEEE 1800-2023 §13.4: automatic function creates new scope for each call
    function automatic int find_power_of_two(int n);
        int power = 0;
        int value = 1;
        $display("  [FUNC] find_power_of_two(%0d) called", n);
        $display("  [FUNC] Initial: power=%0d, value=%0d", power, value);
        while (value < n) begin
            $display("  [FUNC] Loop iter %0d: value=%0d < n=%0d is %s",
                     power, value, n, (value < n) ? "TRUE" : "FALSE");
            value = value * 2;
            power++;
            $display("  [FUNC] After update: value=%0d, power=%0d", value, power);
            if (power > 20) begin
                $display("  [FUNC] Safety limit hit, returning -1");
                return -1;
            end
        end
        $display("  [FUNC] Loop exit: value=%0d >= n=%0d, power=%0d", value, n, power);
        return power;
    endfunction

    initial begin
        int p1, p2;

        $display("\n=== Test 1: find_power_of_two(64) ===");
        p1 = find_power_of_two(64);
        $display("Result: %0d (expected 6)", p1);

        $display("\n=== Test 2: find_power_of_two(100) ===");
        p2 = find_power_of_two(100);
        $display("Result: %0d (expected 7)", p2);

        if (p1 == 6 && p2 == 7) begin
            $display("\nALL TESTS PASSED");
        end else begin
            $display("\nTEST FAILED: p1=%0d (expected 6), p2=%0d (expected 7)", p1, p2);
            $fatal(1, "While loop return test failed");
        end

        $finish;
    end
endmodule
