/*
:name: test_foreach
:description: Foreach loops
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach.expected
*/
// IEEE 1800-2023 Section 12.7.3: Foreach loops
module test_foreach;
    int arr[5];
    int sum;
    int md[2][3];

    initial begin
        // Initialize array
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        arr[3] = 4;
        arr[4] = 5;

        // Basic foreach
        sum = 0;
        foreach (arr[i])
            sum = sum + arr[i];
        if (sum == 15)  // 1+2+3+4+5
            $display("PASS: basic foreach");
        else
            $display("FAIL: foreach = %0d", sum);

        // Foreach index access
        foreach (arr[i])
            arr[i] = arr[i] * 2;
        sum = 0;
        foreach (arr[i])
            sum = sum + arr[i];
        if (sum == 30)  // 2+4+6+8+10
            $display("PASS: foreach modify");
        else
            $display("FAIL: modify = %0d", sum);

        // 2D foreach
        foreach (md[i, j])
            md[i][j] = i * 3 + j + 1;
        sum = 0;
        foreach (md[i, j])
            sum = sum + md[i][j];
        if (sum == 21)  // 1+2+3+4+5+6
            $display("PASS: 2D foreach");
        else
            $display("FAIL: 2D = %0d", sum);

        $display("TEST PASSED: foreach loop tests completed");
        $finish;
    end
endmodule
