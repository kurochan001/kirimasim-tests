/*
:name: test_assign_proc
:description: Test: Procedural continuous assignment
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_proc.expected
*/
// Test: Procedural continuous assignment
// Tests assign statement within procedural blocks

module test_assign_proc;
    reg [7:0] proc_out;
    reg [7:0] data_in;
    reg enable;

    reg [3:0] counter;
    reg [15:0] wide_out;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        proc_out = 8'h00;
        data_in = 8'hAA;
        enable = 0;
        counter = 4'h0;
        wide_out = 16'h0000;
        #1;

        // Test 1: Procedural continuous assignment
        assign proc_out = data_in;
        #1;
        if (proc_out == 8'hAA) begin
            $display("PASS: Test 1a - Procedural assign connects signal");
            pass_count++;
        end else begin
            $display("FAIL: Test 1a - expected 0xAA, got 0x%0h", proc_out);
            fail_count++;
        end

        // Test 1b: Source change propagates
        data_in = 8'h55;
        #1;
        if (proc_out == 8'h55) begin
            $display("PASS: Test 1b - Source change propagates through assign");
            pass_count++;
        end else begin
            $display("FAIL: Test 1b - expected 0x55, got 0x%0h", proc_out);
            fail_count++;
        end

        // Test 2: Deassign then regular assignment
        deassign proc_out;
        proc_out = 8'h12;
        #1;
        if (proc_out == 8'h12) begin
            $display("PASS: Test 2 - After deassign, regular assignment works");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0x12, got 0x%0h", proc_out);
            fail_count++;
        end

        // Test 3: Conditional procedural assign
        if (enable == 0) begin
            assign counter = 4'hF;
        end
        #1;
        if (counter == 4'hF) begin
            $display("PASS: Test 3 - Conditional procedural assign");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0xF, got 0x%0h", counter);
            fail_count++;
        end
        deassign counter;

        // Test 4: Wide signal procedural assign
        assign wide_out = {data_in, 8'hBC};
        #1;
        if (wide_out == 16'h55BC) begin
            $display("PASS: Test 4a - Wide procedural assign with expression");
            pass_count++;
        end else begin
            $display("FAIL: Test 4a - expected 0x55BC, got 0x%0h", wide_out);
            fail_count++;
        end

        data_in = 8'hDE;
        #1;
        if (wide_out == 16'hDEBC) begin
            $display("PASS: Test 4b - Wide assign tracks source changes");
            pass_count++;
        end else begin
            $display("FAIL: Test 4b - expected 0xDEBC, got 0x%0h", wide_out);
            fail_count++;
        end
        deassign wide_out;

        // Test 5: Re-assign after deassign
        assign proc_out = 8'hEE;
        #1;
        if (proc_out == 8'hEE) begin
            $display("PASS: Test 5 - Re-assign after deassign works");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 0xEE, got 0x%0h", proc_out);
            fail_count++;
        end
        deassign proc_out;

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All procedural assign tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
