/*
:name: test_comb_systask_conversion
:description: Test: System task type conversion and query functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 20.7 11.7 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_systask_conversion.expected
*/
// Test: System task type conversion and query functions
module test_comb_systask_conversion;
    int pass_count;
    integer i_val;
    real r_val;
    logic [31:0] l_val;
    logic [63:0] l64_val;
    shortint si_val;
    longint li_val;
    byte b_val;

    initial begin
        pass_count = 0;

        // $itor / $rtoi
        r_val = $itor(42);
        if (r_val == 42.0) pass_count++;

        i_val = $rtoi(3.7);
        if (i_val == 3) pass_count++;

        i_val = $rtoi(-2.9);
        if (i_val == -2) pass_count++;

        // $realtobits / $bitstoreal: the bit pattern of a real has 64 bits
        l64_val = $realtobits(1.0);
        r_val = $bitstoreal(l64_val);
        if (r_val == 1.0) pass_count++;

        // $signed / $unsigned
        l_val = 32'hFFFF_FFFF;
        i_val = $signed(l_val);
        if (i_val == -1) pass_count++;

        l_val = $unsigned(-1);
        if (l_val == 32'hFFFF_FFFF) pass_count++;

        // $size / $left / $right / $low / $high / $increment
        begin
            logic [7:0] arr [0:3];
            i_val = $size(arr);
            if (i_val == 4) pass_count++;

            i_val = $left(arr);
            if (i_val == 0) pass_count++;

            i_val = $right(arr);
            if (i_val == 3) pass_count++;

            i_val = $low(arr);
            if (i_val == 0) pass_count++;

            i_val = $high(arr);
            if (i_val == 3) pass_count++;

            i_val = $increment(arr);
            if (i_val == -1) pass_count++;  // [0:3]: left < right (20.7)
        end

        // $dimensions / $unpacked_dimensions
        begin
            logic [7:0] vec;
            i_val = $dimensions(vec);
            if (i_val == 1) pass_count++;
        end

        // Type casting
        b_val = byte'(256);
        if (b_val == 0) pass_count++;

        si_val = shortint'(70000);
        if (si_val == 4464) pass_count++;  // 70000 - 65536

        li_val = longint'(42);
        if (li_val == 42) pass_count++;

        $display("pass_count = %0d", pass_count);
        if (pass_count == 16)
            $display("PASS: test_comb_systask_conversion");
        else
            $display("FAIL: test_comb_systask_conversion (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
