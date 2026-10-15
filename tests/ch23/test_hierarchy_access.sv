/*
:name: test_hierarchy_access
:description: Reading and writing variables through hierarchical names
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_access.expected
*/
// Reading and writing variables through hierarchical names
module sub_module;
    logic [7:0] data;
    logic valid;
    logic [15:0] addr;

    initial begin
        data = 8'hAB;
        valid = 1'b1;
        addr = 16'hCAFE;
    end
endmodule

module mid_module;
    logic [31:0] counter;
    sub_module sub();

    initial begin
        counter = 32'h12345678;
    end
endmodule

module test_hierarchy_access;
    int pass_count = 0;
    int total_tests = 8;

    mid_module dut();
    sub_module direct_sub();

    initial begin
        #1;

        // Test 1: Access nested signal (dut.sub.data)
        if (dut.sub.data == 8'hAB) begin
            $display("Test 1 PASS: dut.sub.data = %h", dut.sub.data);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: dut.sub.data = %h, expected AB", dut.sub.data);
        end

        // Test 2: Access nested signal (dut.sub.valid)
        if (dut.sub.valid == 1'b1) begin
            $display("Test 2 PASS: dut.sub.valid = %b", dut.sub.valid);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: dut.sub.valid = %b, expected 1", dut.sub.valid);
        end

        // Test 3: Access mid-level signal (dut.counter)
        if (dut.counter == 32'h12345678) begin
            $display("Test 3 PASS: dut.counter = %h", dut.counter);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: dut.counter = %h, expected 12345678", dut.counter);
        end

        // Test 4: Access nested address (dut.sub.addr)
        if (dut.sub.addr == 16'hCAFE) begin
            $display("Test 4 PASS: dut.sub.addr = %h", dut.sub.addr);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: dut.sub.addr = %h, expected CAFE", dut.sub.addr);
        end

        // Test 5: Write to hierarchical path
        dut.sub.data = 8'hCD;
        #1;
        if (dut.sub.data == 8'hCD) begin
            $display("Test 5 PASS: Write to dut.sub.data successful");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Write to dut.sub.data failed");
        end

        // Test 6: Direct sub-module access
        if (direct_sub.data == 8'hAB) begin
            $display("Test 6 PASS: direct_sub.data = %h", direct_sub.data);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: direct_sub.data = %h, expected AB", direct_sub.data);
        end

        // Test 7: Multiple hierarchical writes
        dut.counter = 32'hDEADBEEF;
        dut.sub.valid = 1'b0;
        #1;
        if (dut.counter == 32'hDEADBEEF && dut.sub.valid == 1'b0) begin
            $display("Test 7 PASS: Multiple hierarchical writes successful");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: Multiple hierarchical writes failed");
        end

        // Test 8: Read-modify-write via hierarchy
        dut.sub.addr = dut.sub.addr + 16'h0001;
        #1;
        if (dut.sub.addr == 16'hCAFF) begin
            $display("Test 8 PASS: Read-modify-write via hierarchy successful");
            pass_count++;
        end else begin
            $display("Test 8 FAIL: dut.sub.addr = %h, expected CAFF", dut.sub.addr);
        end

        $display("PASS: hierarchy_access (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
