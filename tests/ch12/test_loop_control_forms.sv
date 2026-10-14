/*
:name: test_loop_control_forms
:description: Loop statements with break and continue (IEEE 1800-2023 Sections 12.7 and 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7 12.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_loop_control_forms.expected
*/
// IEEE 1800-2023 Sections 12.7 and 12.8 - Loop statements and jump statements
// Tests: for, while, do-while, repeat, foreach, break, continue
module test_loop_control_forms;
    int passed = 0;
    int failed = 0;
    int counter;

    initial begin
        // Test basic for loop
        counter = 0;
        for (int i = 0; i < 10; i++) begin
            counter++;
        end
        if (counter == 10) passed++; else begin failed++; $display("FAIL: for"); end

        // Test for loop with step
        counter = 0;
        for (int i = 0; i < 20; i += 2) begin
            counter++;
        end
        if (counter == 10) passed++; else begin failed++; $display("FAIL: for step"); end

        // Test while loop
        counter = 0;
        while (counter < 5) begin
            counter++;
        end
        if (counter == 5) passed++; else begin failed++; $display("FAIL: while"); end

        // Test do-while loop
        counter = 0;
        do begin
            counter++;
        end while (counter < 3);
        if (counter == 3) passed++; else begin failed++; $display("FAIL: do-while"); end

        // Test repeat loop
        counter = 0;
        repeat(7) begin
            counter++;
        end
        if (counter == 7) passed++; else begin failed++; $display("FAIL: repeat"); end

        // Test forever with break
        counter = 0;
        forever begin
            counter++;
            if (counter >= 4) break;
        end
        if (counter == 4) passed++; else begin failed++; $display("FAIL: forever break"); end

        // Test continue
        counter = 0;
        for (int i = 0; i < 10; i++) begin
            if (i % 2 == 0) continue;
            counter++;
        end
        if (counter == 5) passed++; else begin failed++; $display("FAIL: continue"); end

        // Test nested loops
        counter = 0;
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                counter++;
            end
        end
        if (counter == 9) passed++; else begin failed++; $display("FAIL: nested"); end

        begin
            static int arr[5] = '{1, 2, 3, 4, 5};
            counter = 0;
            foreach (arr[i]) begin
                counter += arr[i];
            end
            if (counter == 15) passed++; else begin failed++; $display("FAIL: foreach"); end
        end

        // Test foreach with dynamic array
        begin
            int dyn_arr[];
            dyn_arr = new[4];
            dyn_arr[0] = 10;
            dyn_arr[1] = 20;
            dyn_arr[2] = 30;
            dyn_arr[3] = 40;
            counter = 0;
            foreach (dyn_arr[i]) begin
                counter += dyn_arr[i];
            end
            if (counter == 100) passed++; else begin failed++; $display("FAIL: foreach dyn"); end
        end

        // Test break in nested loop
        counter = 0;
        for (int i = 0; i < 5; i++) begin
            for (int j = 0; j < 5; j++) begin
                counter++;
                if (j == 2) break;
            end
        end
        if (counter == 15) passed++; else begin failed++; $display("FAIL: nested break"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d loop control tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
