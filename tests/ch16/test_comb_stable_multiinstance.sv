/*
:name: test_comb_stable_multiinstance
:description: Test: $stable/$changed across multiple module instances with same signal names
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_stable_multiinstance.expected
*/
// Test: $stable/$changed across multiple module instances with same signal names
// IEEE 1800-2023 §16.9.3

module sub(input logic clk, input logic sig, output logic stable_out, output logic changed_out);
    always @(posedge clk) begin
        stable_out <= $stable(sig);
        changed_out <= $changed(sig);
    end
endmodule

module test_comb_stable_multiinstance;
    logic clk = 0;
    logic sig0, sig1;
    logic stable0, stable1;
    logic changed0, changed1;
    int pass = 0, fail = 0;

    // Two instances with same port name "sig"
    sub u0(.clk(clk), .sig(sig0), .stable_out(stable0), .changed_out(changed0));
    sub u1(.clk(clk), .sig(sig1), .stable_out(stable1), .changed_out(changed1));

    always #5 clk = ~clk;

    initial begin
        // Initialize: both signals at 0
        sig0 = 0;
        sig1 = 0;

        // Cycle 1: establish history
        @(posedge clk);
        #1;

        // Cycle 2: both still 0 -> both should be stable
        @(posedge clk);
        #1;

        // Test 1: Both signals unchanged -> both $stable should be 1
        if (stable0 === 1'b1) pass++; else begin fail++; $display("FAIL T1a: u0.stable=%b expected 1", stable0); end
        if (stable1 === 1'b1) pass++; else begin fail++; $display("FAIL T1b: u1.stable=%b expected 1", stable1); end

        // Cycle 3: change sig0 only, sig1 stays
        sig0 = 1;
        @(posedge clk);
        #1;

        // Test 2: sig0 changed -> stable0=0, sig1 unchanged -> stable1=1
        if (stable0 === 1'b0) pass++; else begin fail++; $display("FAIL T2a: u0.stable=%b expected 0 (sig0 changed)", stable0); end
        if (stable1 === 1'b1) pass++; else begin fail++; $display("FAIL T2b: u1.stable=%b expected 1 (sig1 unchanged)", stable1); end
        if (changed0 === 1'b1) pass++; else begin fail++; $display("FAIL T2c: u0.changed=%b expected 1", changed0); end
        if (changed1 === 1'b0) pass++; else begin fail++; $display("FAIL T2d: u1.changed=%b expected 0", changed1); end

        // Cycle 4: sig0 stays at 1, change sig1
        sig1 = 1;
        @(posedge clk);
        #1;

        // Test 3: sig0 unchanged -> stable0=1, sig1 changed -> stable1=0
        if (stable0 === 1'b1) pass++; else begin fail++; $display("FAIL T3a: u0.stable=%b expected 1 (sig0 unchanged)", stable0); end
        if (stable1 === 1'b0) pass++; else begin fail++; $display("FAIL T3b: u1.stable=%b expected 0 (sig1 changed)", stable1); end

        // Cycle 5: both stay at 1
        @(posedge clk);
        #1;

        // Test 4: both unchanged -> both stable
        if (stable0 === 1'b1) pass++; else begin fail++; $display("FAIL T4a: u0.stable=%b expected 1", stable0); end
        if (stable1 === 1'b1) pass++; else begin fail++; $display("FAIL T4b: u1.stable=%b expected 1", stable1); end

        // Cycle 6: change both
        sig0 = 0;
        sig1 = 0;
        @(posedge clk);
        #1;

        // Test 5: both changed -> both unstable
        if (stable0 === 1'b0) pass++; else begin fail++; $display("FAIL T5a: u0.stable=%b expected 0", stable0); end
        if (stable1 === 1'b0) pass++; else begin fail++; $display("FAIL T5b: u1.stable=%b expected 0", stable1); end
        if (changed0 === 1'b1) pass++; else begin fail++; $display("FAIL T5c: u0.changed=%b expected 1", changed0); end
        if (changed1 === 1'b1) pass++; else begin fail++; $display("FAIL T5d: u1.changed=%b expected 1", changed1); end

        $display("stable_multiinstance: pass=%0d fail=%0d", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
