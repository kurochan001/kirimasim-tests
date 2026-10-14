/*
:name: test_begin_end
:description: Sequential blocks
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_begin_end.expected
*/
// IEEE 1800-2023 Section 9.3.1: Sequential blocks
module test_begin_end;
    int a, b, c;
    int local_var;

    initial begin
        // Simple begin-end
        begin
            a = 1;
            b = 2;
            c = a + b;
        end
        if (c == 3)
            $display("PASS: simple begin-end");
        else
            $display("FAIL: simple = %0d", c);

        // Named begin-end
        begin : named_block
            int x;
            x = 10;
            a = x;
        end
        if (a == 10)
            $display("PASS: named begin-end");
        else
            $display("FAIL: named = %0d", a);

        // Nested begin-end
        begin
            a = 0;
            begin
                a = a + 1;
                begin
                    a = a + 1;
                end
            end
        end
        if (a == 2)
            $display("PASS: nested begin-end");
        else
            $display("FAIL: nested = %0d", a);

        // Begin-end with declarations
        begin
            int temp;
            temp = 100;
            a = temp;
        end
        if (a == 100)
            $display("PASS: begin-end with decl");
        else
            $display("FAIL: decl = %0d", a);

        // Empty begin-end
        begin
        end
        $display("PASS: empty begin-end");

        $display("TEST PASSED: begin-end tests completed");
        $finish;
    end
endmodule
