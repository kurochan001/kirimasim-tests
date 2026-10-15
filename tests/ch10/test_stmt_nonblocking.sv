/*
:name: test_stmt_nonblocking
:description: Non-blocking assignments test
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stmt_nonblocking.expected
*/
// Non-blocking assignments test
module test_nonblocking;
    logic clk = 0;
    logic [7:0] a, b, c, d, e;
    int pass_count = 0;
    int cycle = 0;

    always #5 clk = ~clk;

    initial begin
        a = 0; b = 0; c = 0; d = 0; e = 0;
    end

    always @(posedge clk) begin
        cycle++;

        case (cycle)
            1: begin
                // Scenario 1: Simple non-blocking assignment
                a <= 8'd10;
            end
            2: begin
                if (a == 8'd10) pass_count++;
                else $display("FAIL: Simple non-blocking assignment a=%0d", a);
                // Scenario 2: Multiple non-blocking assignments
                b <= 8'd20;
                c <= 8'd30;
            end
            3: begin
                if (b == 8'd20 && c == 8'd30) pass_count++;
                else $display("FAIL: Multiple non-blocking assignments b=%0d c=%0d", b, c);
                // Scenario 3: Swap using non-blocking
                d <= 8'd5;
                e <= 8'd15;
            end
            4: begin
                d <= e;
                e <= d;
            end
            5: begin
                if (d == 8'd15 && e == 8'd5) pass_count++;
                else $display("FAIL: Swap using non-blocking d=%0d e=%0d", d, e);
                // Scenario 4: Non-blocking with expression
                a <= a + 8'd5;
            end
            6: begin
                if (a == 8'd15) pass_count++;
                else $display("FAIL: Non-blocking with expression a=%0d", a);
                // Scenario 5: Chained non-blocking
                b <= 8'd100;
            end
            7: begin
                c <= b;
            end
            8: begin
                if (c == 8'd100) pass_count++;
                else $display("FAIL: Chained non-blocking c=%0d", c);

                if (pass_count == 5) $display("PASS");
                else $display("FAIL: pass_count=%0d", pass_count);
                $finish;
            end
        endcase
    end
endmodule
