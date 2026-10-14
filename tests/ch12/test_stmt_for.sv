/*
:name: test_stmt_for
:description: Test for for loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_for.expected
*/
// Test for for loop
// IEEE 1800-2023 §12.7.1: for loop
module test_stmt_for;
    initial begin
        int sum;
        int arr[5];
        int i;

        // Simple for loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum += i;
        end
        if (sum != 10) $display("FAIL: Simple for %0d", sum);

        // For loop with declaration
        sum = 0;
        for (int j = 0; j < 3; j++) begin
            sum += j * 2;
        end
        if (sum != 6) $display("FAIL: For with decl %0d", sum);

        // Nested for
        sum = 0;
        for (int x = 0; x < 3; x++) begin
            for (int y = 0; y < 3; y++) begin
                sum++;
            end
        end
        if (sum != 9) $display("FAIL: Nested for %0d", sum);

        // For with break
        sum = 0;
        for (i = 0; i < 100; i++) begin
            if (i >= 5) break;
            sum += i;
        end
        if (sum != 10) $display("FAIL: For with break %0d", sum);

        $display("PASS: For loop");
        $finish;
    end
endmodule
