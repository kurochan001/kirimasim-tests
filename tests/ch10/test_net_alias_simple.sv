/*
:name: test_net_alias_simple
:description: Simple alias test
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_alias_simple.expected
*/
// Simple alias test
module test_net_alias_simple;
    wire a, b;
    alias a = b;

    reg drv;
    assign b = drv;

    initial begin
        drv = 0;
        #1;
        $display("drv=%b, a=%b, b=%b", drv, a, b);
        if (a === 1'b0 && b === 1'b0) begin
            $display("TEST1 PASS: a and b are 0");
        end else begin
            $display("TEST1 FAIL: expected a=0, b=0, got a=%b, b=%b", a, b);
        end

        drv = 1;
        #1;
        $display("drv=%b, a=%b, b=%b", drv, a, b);
        if (a === 1'b1 && b === 1'b1) begin
            $display("TEST2 PASS: a and b are 1");
        end else begin
            $display("TEST2 FAIL: expected a=1, b=1, got a=%b, b=%b", a, b);
        end

        $finish;
    end
endmodule
