/*
:name: test_control_flow
:description: Test 1: For loop
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 12.5 12.5.1 12.7
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_control_flow.expected
*/
// IEEE 1800-2023 Section 12

module test_control_flow;
    int i, j, sum, result;
    int arr[5] = '{1, 2, 3, 4, 5};

    initial begin
        // Test 1: For loop
        sum = 0;
        for (i = 0; i < 5; i++) begin
            sum = sum + arr[i];
        end
        if (sum == 15)
            $display("PASS: For loop sum = %0d", sum);
        else
            $display("FAIL: For loop got %0d", sum);

        // Test 2: While loop
        i = 0;
        sum = 0;
        while (i < 5) begin
            sum = sum + arr[i];
            i++;
        end
        if (sum == 15)
            $display("PASS: While loop sum = %0d", sum);
        else
            $display("FAIL: While loop got %0d", sum);

        // Test 3: Repeat loop
        i = 0;
        repeat (5) begin
            i++;
        end
        if (i == 5)
            $display("PASS: Repeat loop count = %0d", i);
        else
            $display("FAIL: Repeat loop got %0d", i);

        // Test 4: Do-while loop
        i = 0;
        do begin
            i++;
        end while (i < 10);
        if (i == 10)
            $display("PASS: Do-while loop = %0d", i);
        else
            $display("FAIL: Do-while got %0d", i);

        // Test 5: Foreach
        sum = 0;
        foreach (arr[k]) begin
            sum = sum + arr[k];
        end
        if (sum == 15)
            $display("PASS: Foreach sum = %0d", sum);
        else
            $display("FAIL: Foreach got %0d", sum);

        // Test 6: If-else chain
        result = 5;
        if (result < 0)
            result = 0;
        else if (result < 5)
            result = 1;
        else if (result == 5)
            result = 2;
        else
            result = 3;
        if (result == 2)
            $display("PASS: If-else chain result = %0d", result);
        else
            $display("FAIL: If-else got %0d", result);

        // Test 7: Case statement
        result = 2;
        case (result)
            0: result = 10;
            1: result = 20;
            2: result = 30;
            default: result = 40;
        endcase
        if (result == 30)
            $display("PASS: Case statement result = %0d", result);
        else
            $display("FAIL: Case got %0d", result);

        // Test 8: Casex
        result = 4'b10x1;
        casex (result)
            4'b0xxx: result = 1;
            4'b10xx: result = 2;
            default: result = 3;
        endcase
        if (result == 2)
            $display("PASS: Casex result = %0d", result);
        else
            $display("FAIL: Casex got %0d", result);

        // Test 9: Casez
        result = 4'b10z1;
        casez (result)
            4'b0???: result = 1;
            4'b10??: result = 2;
            default: result = 3;
        endcase
        if (result == 2)
            $display("PASS: Casez result = %0d", result);
        else
            $display("FAIL: Casez got %0d", result);

        // Test 10: Continue in loop
        sum = 0;
        for (i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            sum = sum + i;
        end
        // Sum of odd numbers 1,3,5,7,9 = 25
        if (sum == 25)
            $display("PASS: Continue in loop sum = %0d", sum);
        else
            $display("FAIL: Continue got %0d", sum);

        $display("TEST PASSED: control flow completed");
        $finish;
    end
endmodule
