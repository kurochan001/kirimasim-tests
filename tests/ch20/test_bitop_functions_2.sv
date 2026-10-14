/*
:name: test_bitop_functions_2
:description: Bit vector query functions on all-zero, all-one, mixed and unknown values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitop_functions_2.expected
*/
// IEEE 1800-2023 Section 20.9 - Bit vector system functions
// Tests: $countones, $countbits, $onehot, $onehot0, $isunknown
module test_bitop_functions_2;
    logic [7:0] val8;
    logic [15:0] val16;
    logic [31:0] val32;
    int count;
    int passed = 0;
    int failed = 0;

    initial begin
        // $countones tests
        val8 = 8'b0000_0000;
        count = $countones(val8);
        if (count == 0) passed++; else begin failed++; $display("FAIL: countones(0) = %0d", count); end

        val8 = 8'b1111_1111;
        count = $countones(val8);
        if (count == 8) passed++; else begin failed++; $display("FAIL: countones(ff) = %0d", count); end

        val8 = 8'b1010_1010;
        count = $countones(val8);
        if (count == 4) passed++; else begin failed++; $display("FAIL: countones(aa) = %0d", count); end

        val16 = 16'hAAAA;
        count = $countones(val16);
        if (count == 8) passed++; else begin failed++; $display("FAIL: countones(aaaa) = %0d", count); end

        val32 = 32'hFFFF_0000;
        count = $countones(val32);
        if (count == 16) passed++; else begin failed++; $display("FAIL: countones(ffff0000) = %0d", count); end

        // $countbits tests - count specific bit values
        val8 = 8'b1010_1010;
        count = $countbits(val8, 1'b0);
        if (count == 4) passed++; else begin failed++; $display("FAIL: countbits 0 = %0d", count); end

        count = $countbits(val8, 1'b1);
        if (count == 4) passed++; else begin failed++; $display("FAIL: countbits 1 = %0d", count); end

        // $onehot tests - exactly one bit is 1
        val8 = 8'b0000_0001;
        if ($onehot(val8)) passed++; else begin failed++; $display("FAIL: onehot(01)"); end

        val8 = 8'b1000_0000;
        if ($onehot(val8)) passed++; else begin failed++; $display("FAIL: onehot(80)"); end

        val8 = 8'b0000_0000;
        if (!$onehot(val8)) passed++; else begin failed++; $display("FAIL: !onehot(00)"); end

        val8 = 8'b0000_0011;
        if (!$onehot(val8)) passed++; else begin failed++; $display("FAIL: !onehot(03)"); end

        // $onehot0 tests - at most one bit is 1
        val8 = 8'b0000_0000;
        if ($onehot0(val8)) passed++; else begin failed++; $display("FAIL: onehot0(00)"); end

        val8 = 8'b0000_0001;
        if ($onehot0(val8)) passed++; else begin failed++; $display("FAIL: onehot0(01)"); end

        val8 = 8'b0000_0011;
        if (!$onehot0(val8)) passed++; else begin failed++; $display("FAIL: !onehot0(03)"); end

        // $isunknown tests
        val8 = 8'b0000_0000;
        if (!$isunknown(val8)) passed++; else begin failed++; $display("FAIL: !isunknown(00)"); end

        val8 = 8'b0000_000x;
        if ($isunknown(val8)) passed++; else begin failed++; $display("FAIL: isunknown(0x)"); end

        val8 = 8'b0000_000z;
        if ($isunknown(val8)) passed++; else begin failed++; $display("FAIL: isunknown(0z)"); end

        val8 = 8'bxxxx_xxxx;
        if ($isunknown(val8)) passed++; else begin failed++; $display("FAIL: isunknown(xx)"); end

        // Edge cases with wider values
        val32 = 32'h0000_0001;
        if ($onehot(val32)) passed++; else begin failed++; $display("FAIL: onehot32(1)"); end

        val32 = 32'h8000_0000;
        if ($onehot(val32)) passed++; else begin failed++; $display("FAIL: onehot32(msb)"); end

        // Report results
        if (failed == 0)
            $display("PASS: All %0d bit operation tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
