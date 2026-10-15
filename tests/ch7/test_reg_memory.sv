/*
:name: test_reg_memory
:description: Reg array memory operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reg_memory.expected
*/
// Reg array memory operations
module test_reg_memory;
    reg [7:0] mem [0:15];
    reg [7:0] data;
    reg [31:0] wide_mem [0:3];
    int i;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic memory write and read
        mem[0] = 8'hAB;
        data = mem[0];
        if (data == 8'hAB) begin
            $display("PASS: Test 1 - Basic memory write/read");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic memory write/read, got %h", data);
            fail_count++;
        end

        // Test 2: Memory array initialization
        for (i = 0; i < 16; i++) begin
            mem[i] = i * 10;
        end
        if (mem[5] == 50 && mem[10] == 100) begin
            $display("PASS: Test 2 - Memory array initialization");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Memory array initialization");
            fail_count++;
        end

        // Test 3: Memory boundary access
        mem[15] = 8'hFF;
        if (mem[15] == 8'hFF) begin
            $display("PASS: Test 3 - Memory boundary access");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Memory boundary access");
            fail_count++;
        end

        // Test 4: Wide memory operations
        wide_mem[0] = 32'hDEADBEEF;
        wide_mem[1] = 32'hCAFEBABE;
        if (wide_mem[0] == 32'hDEADBEEF && wide_mem[1] == 32'hCAFEBABE) begin
            $display("PASS: Test 4 - Wide memory operations");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Wide memory operations");
            fail_count++;
        end

        // Test 5: Memory copy operation
        mem[0] = 8'h12;
        mem[1] = mem[0];
        if (mem[1] == 8'h12) begin
            $display("PASS: Test 5 - Memory copy operation");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Memory copy operation");
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
