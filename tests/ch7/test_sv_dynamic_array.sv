/*
:name: test_sv_dynamic_array
:description: Dynamic arrays: new[], resize with copy, size() and delete()
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.5.1 7.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sv_dynamic_array.expected
*/
// Dynamic arrays: new[], resize with copy, size() and delete()
module test_sv_dynamic_array;

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    int da[];

    // Check 1: initial size is 0
    if (da.size() == 0) begin pass_cnt++; $display("PASS: initial size == 0"); end
    else begin fail_cnt++; $display("FAIL: initial size = %0d", da.size()); end

    // Check 2: new[4] allocates 4 elements
    da = new[4];
    if (da.size() == 4) begin pass_cnt++; $display("PASS: size after new[4] == 4"); end
    else begin fail_cnt++; $display("FAIL: size after new[4] = %0d", da.size()); end

    // Check 3: write and read elements
    da[0] = 10; da[1] = 20; da[2] = 30; da[3] = 40;
    if (da[2] == 30) begin pass_cnt++; $display("PASS: da[2] == 30"); end
    else begin fail_cnt++; $display("FAIL: da[2] = %0d", da[2]); end

    // Check 4: resize with copy (new[6](da) copies old elements)
    da = new[6](da);
    if (da.size() == 6) begin pass_cnt++; $display("PASS: size after resize == 6"); end
    else begin fail_cnt++; $display("FAIL: size after resize = %0d", da.size()); end

    // Check 5: old data preserved after resize
    if (da[0] == 10 && da[3] == 40) begin pass_cnt++; $display("PASS: old data preserved"); end
    else begin fail_cnt++; $display("FAIL: da[0]=%0d da[3]=%0d", da[0], da[3]); end

    // Check 6: new element is zero-initialized
    if (da[4] == 0 && da[5] == 0) begin pass_cnt++; $display("PASS: new elements zero"); end
    else begin fail_cnt++; $display("FAIL: da[4]=%0d da[5]=%0d", da[4], da[5]); end

    // Check 7: delete clears array
    da.delete();
    if (da.size() == 0) begin pass_cnt++; $display("PASS: size after delete == 0"); end
    else begin fail_cnt++; $display("FAIL: size after delete = %0d", da.size()); end

    // Check 8: new[] with immediate assignment
    da = new[3];
    da[0] = 100; da[1] = 200; da[2] = 300;
    if (da[1] == 200) begin pass_cnt++; $display("PASS: da[1] == 200"); end
    else begin fail_cnt++; $display("FAIL: da[1] = %0d", da[1]); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
