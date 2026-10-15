/*
:name: test_scope_nba
:description: Block-scoped variables with NBA (non-blocking) assignments
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1 10.4.2 23.9 6.21
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_nba.expected
*/
// Block-scoped variables with NBA (non-blocking) assignments
module test_scope_nba;
    int pass_count = 0;

    // Module-level signals
    int x;
    int y;
    logic clk = 0;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        x = 999;
        y = 999;

        // T1: Block-scoped variable with NBA
        begin
            static int x = 0;
            x <= 42;
            #1;
            if (x == 42) begin
                $display("T1: PASS - block NBA x=%0d", x);
                pass_count++;
            end else
                $display("T1: FAIL - block x=%0d (expect 42)", x);
        end

        // T2: Module-level x unchanged
        if (x == 999) begin
            $display("T2: PASS - module x=%0d", x);
            pass_count++;
        end else
            $display("T2: FAIL - module x=%0d (expect 999)", x);

        // T3: Multiple block-scoped NBAs
        begin
            static int a = 0;
            static int b = 0;
            a <= 10;
            b <= 20;
            #1;
            if (a == 10 && b == 20) begin
                $display("T3: PASS - a=%0d b=%0d", a, b);
                pass_count++;
            end else
                $display("T3: FAIL - a=%0d b=%0d", a, b);
        end

        // T4: Sequential blocks with same variable name
        begin
            static int y = 0;
            y <= 50;
            #1;
            if (y == 50) begin
                $display("T4a: PASS - y=%0d", y);
            end
        end
        begin
            static int y = 0;
            y <= 60;
            #1;
            if (y == 60) begin
                $display("T4b: PASS - y=%0d", y);
                pass_count++;
            end else
                $display("T4: FAIL - y=%0d (expect 60)", y);
        end

        // T5: Module-level y unchanged
        if (y == 999) begin
            $display("T5: PASS - module y=%0d", y);
            pass_count++;
        end else
            $display("T5: FAIL - module y=%0d (expect 999)", y);

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 5)
            $display("PASS: test_scope_nba");
        else
            $display("FAIL: test_scope_nba (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
