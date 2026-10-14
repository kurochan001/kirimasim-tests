/*
:name: test_force_multibit
:description: force with wide vectors
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_multibit.expected
*/
// IEEE 1800-2023 §10.6.2: force with wide vectors
module test_force_multibit;
    logic [31:0] wide32;
    logic [63:0] wide64;
    logic [127:0] wide128;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Force 32-bit
        wide32 = 32'h0;
        force wide32 = 32'hDEADBEEF;
        #1;
        if (wide32 == 32'hDEADBEEF) begin
            $display("Test 1 PASS: force 32-bit=%08h", wide32);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %08h", wide32);
            fail_count++;
        end
        release wide32;

        // Test 2: Force 64-bit
        wide64 = 64'h0;
        force wide64 = 64'hCAFEBABE_12345678;
        #1;
        if (wide64 == 64'hCAFEBABE_12345678) begin
            $display("Test 2 PASS: force 64-bit=%016h", wide64);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %016h", wide64);
            fail_count++;
        end
        release wide64;

        // Test 3: Force 128-bit
        wide128 = 128'h0;
        force wide128 = 128'hAAAABBBBCCCCDDDD_EEEEFFFF00001111;
        #1;
        if (wide128 == 128'hAAAABBBBCCCCDDDD_EEEEFFFF00001111) begin
            $display("Test 3 PASS: force 128-bit=%032h", wide128);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %032h", wide128);
            fail_count++;
        end
        release wide128;

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
