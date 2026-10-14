/*
:name: test_control_flow_4
:description: Chapter 12: Procedural programming statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 12.5 12.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_control_flow_4.expected
*/
// IEEE 1800-2023 Chapter 12: Procedural programming statements
// §12.4 Conditional statements and §12.5 Case statements

module test_control_flow;
    int test_count;
    int pass_count;

    int value;
    int result;

    initial begin
        test_count = 0;
        pass_count = 0;

        // §12.4 if-else
        value = 10;

        // Test 1: Simple if
        result = 0;
        if (value > 5) result = 1;
        test_count++;
        if (result == 1) pass_count++;
        else $display("FAIL: Simple if - result=%0d", result);

        // Test 2: if-else
        if (value > 20)
            result = 2;
        else
            result = 3;
        test_count++;
        if (result == 3) pass_count++;
        else $display("FAIL: if-else - result=%0d", result);

        // Test 3: if-else if-else
        if (value < 5)
            result = 1;
        else if (value < 15)
            result = 2;
        else
            result = 3;
        test_count++;
        if (result == 2) pass_count++;
        else $display("FAIL: if-else if - result=%0d", result);

        // §12.5 case statement
        value = 2;

        // Test 4: Simple case
        case (value)
            0: result = 10;
            1: result = 20;
            2: result = 30;
            default: result = 0;
        endcase
        test_count++;
        if (result == 30) pass_count++;
        else $display("FAIL: case - result=%0d", result);

        // Test 5: case with default
        value = 99;
        case (value)
            0: result = 10;
            1: result = 20;
            default: result = 100;
        endcase
        test_count++;
        if (result == 100) pass_count++;
        else $display("FAIL: case default - result=%0d", result);

        // Test 6: casez (don't care)
        value = 4'b1001;
        casez (value)
            4'b1??1: result = 1;  // Matches
            4'b0??0: result = 2;
            default: result = 0;
        endcase
        test_count++;
        if (result == 1) pass_count++;
        else $display("FAIL: casez - result=%0d", result);

        // Test 7: casex (X don't care)
        value = 4'b1x01;
        casex (value)
            4'b1x01: result = 5;
            default: result = 0;
        endcase
        test_count++;
        if (result == 5) pass_count++;
        else $display("FAIL: casex - result=%0d", result);

        $display("Chapter 12.4-5 Control Flow: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
