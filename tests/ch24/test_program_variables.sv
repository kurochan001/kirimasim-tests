/*
:name: test_program_variables
:description: Chapter 24: Programs
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_variables.expected
*/
// IEEE 1800-2023 Chapter 24: Programs
// §24.4 Program variables and clocking

`timescale 1ns/1ps

program test_program_variables;
    // Test program-specific variable behavior

    int test_count;
    int pass_count;

    // Program variables (automatic by default in program blocks)
    int prog_var;
    static int static_var;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Program variable initialization
        prog_var = 10;
        test_count++;
        if (prog_var == 10) pass_count++;
        else $display("FAIL: Program var init - prog_var=%0d (expected 10)", prog_var);

        // Test 2: Static variable in program
        static_var = 20;
        test_count++;
        if (static_var == 20) pass_count++;
        else $display("FAIL: Static var - static_var=%0d (expected 20)", static_var);

        // Test 3: Multiple assignments
        prog_var = prog_var + 5;
        static_var = static_var * 2;
        test_count++;
        if (prog_var == 15 && static_var == 40) pass_count++;
        else $display("FAIL: Multiple assign - prog_var=%0d, static_var=%0d (expected 15, 40)",
                      prog_var, static_var);

        $display("Chapter 24.4 Program Variables: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endprogram
