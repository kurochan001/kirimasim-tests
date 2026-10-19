/*
:name: test_assignment_kinds
:description: Blocking, nonblocking and compound assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_kinds.expected
*/
// IEEE 1800-2023 Section 10 - Blocking, nonblocking and compound assignments
// Tests: blocking, non-blocking, continuous
module test_assignment_kinds;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic [7:0] a, b, c;
    logic [7:0] reg_val;

    // Continuous assignment
    assign c = a + b;

    always #5 clk = ~clk;

    // Non-blocking in always_ff
    always_ff @(posedge clk) begin
        reg_val <= a;
    end

    initial begin
        a = 0;
        b = 0;
        #1;

        // Test continuous assignment
        a = 10;
        b = 20;
        #1;
        if (c == 30) passed++; else begin failed++; $display("FAIL: cont = %0d", c); end

        // Test blocking assignment
        a = 50;
        if (a == 50) passed++; else begin failed++; $display("FAIL: blocking"); end

        // Test non-blocking
        @(posedge clk);
        @(posedge clk);
        #1;
        if (reg_val == 50) passed++; else begin failed++; $display("FAIL: non-blocking = %0d", reg_val); end

        // Test compound assignment
        a = 10;
        a += 5;
        if (a == 15) passed++; else begin failed++; $display("FAIL: +="); end

        a -= 3;
        if (a == 12) passed++; else begin failed++; $display("FAIL: -="); end

        // Test part select assignment
        a = 8'h00;
        a[7:4] = 4'hA;
        if (a == 8'hA0) passed++; else begin failed++; $display("FAIL: part = %h", a); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d assignment tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
