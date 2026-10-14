/*
:name: test_nba_typecast_select
:description: test_nba_typecast_select.sv
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_typecast_select.expected
*/
// test_nba_typecast_select.sv
// IEEE 1800-2023 §10.4.2: nonblocking assignments to part-selects of a
// vector and of an array element, including several part-selects of one
// variable in the same time step.

module test_nba_typecast_select;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic NBA part-select on logic vector
    logic [15:0] sig1;
    // Test 2: NBA part-select on array element
    logic [7:0] mem [0:3];
    // Test 3: Multiple NBA part-selects to same signal (merge)
    logic [31:0] sig2;

    initial begin
        // Test 1: NBA part-select assignment
        sig1 = 16'h0000;
        sig1[7:0] <= 8'hAB;
        sig1[15:8] <= 8'hCD;
        #1;
        if (sig1 === 16'hCDAB) begin
            $display("PASS: Test 1 - NBA part-select on logic vector: %h", sig1);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 16'hCDAB, got %h", sig1);
            fail_count++;
        end

        // Test 2: NBA part-select on array element
        mem[0] = 8'h00;
        mem[1] = 8'h00;
        mem[0][3:0] <= 4'hF;
        mem[1][7:4] <= 4'hA;
        #1;
        if (mem[0] === 8'h0F && mem[1] === 8'hA0) begin
            $display("PASS: Test 2 - NBA part-select on array element: mem[0]=%h, mem[1]=%h", mem[0], mem[1]);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected mem[0]=0F mem[1]=A0, got %h %h", mem[0], mem[1]);
            fail_count++;
        end

        // Test 3: Multiple NBA part-selects to non-overlapping ranges
        sig2 = 32'h00000000;
        sig2[7:0]   <= 8'h11;
        sig2[15:8]  <= 8'h22;
        sig2[23:16] <= 8'h33;
        sig2[31:24] <= 8'h44;
        #1;
        if (sig2 === 32'h44332211) begin
            $display("PASS: Test 3 - Multiple NBA part-selects merged: %h", sig2);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 32'h44332211, got %h", sig2);
            fail_count++;
        end

        // Summary
        if (fail_count == 0)
            $display("PASS: All %0d tests passed", pass_count);
        else
            $display("FAIL: %0d/%0d tests failed", fail_count, pass_count + fail_count);

        $finish;
    end
endmodule
