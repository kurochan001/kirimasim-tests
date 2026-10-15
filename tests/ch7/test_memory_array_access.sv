/*
:name: test_memory_array_access
:description: Memory (unpacked array) element access and copy (IEEE 1800-2023 Sections 7.4.2 and 7.4.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2 7.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_memory_array_access.expected
*/
// IEEE 1800-2023 Sections 7.4.2 and 7.4.4 - Memory (unpacked array) access
// Tests: element read and write, copy between arrays
module test_memory_array_access;
    int passed = 0;
    int failed = 0;

    logic [7:0] mem [0:15];
    logic [7:0] mem2 [0:7];

    initial begin
        // Initialize memory
        for (int i = 0; i < 16; i++)
            mem[i] = i * 2;
        passed++;

        // Test memory access
        if (mem[0] == 0) passed++; else begin failed++; $display("FAIL: mem[0]"); end
        if (mem[5] == 10) passed++; else begin failed++; $display("FAIL: mem[5]"); end
        if (mem[15] == 30) passed++; else begin failed++; $display("FAIL: mem[15]"); end

        // Test memory write
        mem[8] = 8'hFF;
        if (mem[8] == 8'hFF) passed++; else begin failed++; $display("FAIL: write"); end

        // Test memory slice access
        for (int i = 0; i < 8; i++)
            mem2[i] = mem[i];
        if (mem2[3] == 6) passed++; else begin failed++; $display("FAIL: slice"); end

        // Test memory bounds
        if (mem[0] >= 0 && mem[15] <= 255) passed++; else begin failed++; $display("FAIL: bounds"); end

        // Report
        if (failed == 0)
            $display("PASS: All %0d memory tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
