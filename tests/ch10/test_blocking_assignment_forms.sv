/*
:name: test_blocking_assignment_forms
:description: Blocking assignments to whole variables, bit- and part-selects and array elements, and the += -= ++ -- operators
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.4.1 11.4.2 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_assignment_forms.expected
*/
// IEEE 1800-2023 10.4.1, 11.4.1, 11.4.2, 11.5.1

module test_blocking_assignment_forms;
    logic [31:0] a, b;
    logic [7:0] byte_val;
    logic [15:0] word_val;
    int arr[4];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple assignment
        test_count++;
        a = 32'hDEADBEEF;
        if (a == 32'hDEADBEEF) begin
            $display("Test 1: Simple assign PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL a=%h", a);
        end

        // Test 2: Part select assignment
        test_count++;
        a = 32'h00000000;
        a[7:0] = 8'hFF;
        if (a == 32'h000000FF) begin
            $display("Test 2: Part select PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL a=%h", a);
        end

        // Test 3: Bit select assignment
        test_count++;
        a = 32'h00000000;
        a[31] = 1;
        if (a == 32'h80000000) begin
            $display("Test 3: Bit select PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL a=%h", a);
        end

        // Test 4: Array element assignment
        test_count++;
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        if (arr[0] == 10 && arr[3] == 40) begin
            $display("Test 4: Array element PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Compound assignment +=
        test_count++;
        a = 100;
        a += 50;
        if (a == 150) begin
            $display("Test 5: Compound += PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL a=%0d", a);
        end

        // Test 6: Compound assignment -=
        test_count++;
        a = 100;
        a -= 30;
        if (a == 70) begin
            $display("Test 6: Compound -= PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL a=%0d", a);
        end

        // Test 7: Increment
        test_count++;
        a = 10;
        a++;
        if (a == 11) begin
            $display("Test 7: Increment PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL a=%0d", a);
        end

        // Test 8: Decrement
        test_count++;
        a = 10;
        a--;
        if (a == 9) begin
            $display("Test 8: Decrement PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL a=%0d", a);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
