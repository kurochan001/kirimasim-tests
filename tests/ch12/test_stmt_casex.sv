/*
:name: test_stmt_casex
:description: Casex statements test
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stmt_casex.expected
*/
// Casex statements test
module test_casex;
    logic [3:0] data;
    int result;
    int pass_count = 0;

    initial begin
        // Scenario 1: Casex with don't care in case item
        data = 4'b1001;
        casex (data)
            4'b0xxx: result = 0;
            4'b10xx: result = 1;
            4'b110x: result = 2;
            4'b1110: result = 3;
            default: result = -1;
        endcase
        if (result == 1) pass_count++;
        else $display("FAIL: Casex with don't care in case item result=%0d", result);

        // Scenario 2: Casex matching first pattern
        data = 4'b0111;
        casex (data)
            4'b0xxx: result = 10;
            4'b1xxx: result = 20;
            default: result = -1;
        endcase
        if (result == 10) pass_count++;
        else $display("FAIL: Casex matching first pattern result=%0d", result);

        // Scenario 3: Casex with multiple don't cares
        data = 4'b1010;
        casex (data)
            4'bxx00: result = 100;
            4'bxx01: result = 101;
            4'bxx10: result = 102;
            4'bxx11: result = 103;
            default: result = -1;
        endcase
        if (result == 102) pass_count++;
        else $display("FAIL: Casex with multiple don't cares result=%0d", result);

        // Scenario 4: Casex with X in data (treated as don't care)
        data = 4'b11x0;
        casex (data)
            4'b0000: result = 0;
            4'b1100: result = 1;
            4'b1110: result = 2;
            default: result = -1;
        endcase
        // The x bit matches anything, and the first matching item wins (12.5.1).
        if (result == 1) pass_count++;
        else $display("FAIL: Casex with X in data result=%0d", result);

        // Scenario 5: Casex exact match takes precedence
        data = 4'b1111;
        casex (data)
            4'b1111: result = 50;
            4'b11xx: result = 51;
            4'b1xxx: result = 52;
            default: result = -1;
        endcase
        if (result == 50) pass_count++;
        else $display("FAIL: Casex exact match takes precedence result=%0d", result);

        if (pass_count == 5) $display("PASS");
        else $display("FAIL: pass_count=%0d", pass_count);
        $finish;
    end
endmodule
