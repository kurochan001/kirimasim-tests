/*
:name: test_for_loop
:description: For loops
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop.expected
*/
// IEEE 1800-2023 Section 12.7.1: For loops
module test_for_loop;
    int sum, product;
    int i, j;

    initial begin
        // Basic for loop
        sum = 0;
        for (i = 0; i < 5; i++)
            sum = sum + i;
        if (sum == 10)  // 0+1+2+3+4
            $display("PASS: basic for loop");
        else
            $display("FAIL: sum = %0d", sum);

        // For loop with decrement
        sum = 0;
        for (i = 5; i > 0; i--)
            sum = sum + i;
        if (sum == 15)  // 5+4+3+2+1
            $display("PASS: decrement for");
        else
            $display("FAIL: dec = %0d", sum);

        // Nested for loops
        product = 0;
        for (i = 0; i < 3; i++)
            for (j = 0; j < 3; j++)
                product = product + 1;
        if (product == 9)
            $display("PASS: nested for");
        else
            $display("FAIL: nested = %0d", product);

        // For with step
        sum = 0;
        for (i = 0; i < 10; i = i + 2)
            sum = sum + i;
        if (sum == 20)  // 0+2+4+6+8
            $display("PASS: for with step");
        else
            $display("FAIL: step = %0d", sum);

        $display("TEST PASSED: for loop tests completed");
        $finish;
    end
endmodule
