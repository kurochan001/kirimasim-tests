/*
:name: test_dynamic_resize
:description: Dynamic array new, resize, delete operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_resize.expected
*/
// Dynamic array new, resize, delete operations
module test_dynamic_resize;
    int dyn[];
    int dyn2[];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: new with size
        dyn = new[5];
        if (dyn.size() == 5) begin
            $display("PASS: new[5] creates array of size 5");
            pass_count++;
        end else begin
            $display("FAIL: new[5] - expected size 5, got %0d", dyn.size());
            fail_count++;
        end

        // Test 2: Initialize and verify
        foreach (dyn[i]) dyn[i] = i * 10;
        if (dyn[0] == 0 && dyn[2] == 20 && dyn[4] == 40) begin
            $display("PASS: array initialization works");
            pass_count++;
        end else begin
            $display("FAIL: initialization - expected [0,10,20,30,40]");
            fail_count++;
        end

        // Test 3: resize larger with copy
        dyn = new[8](dyn);
        if (dyn.size() == 8 && dyn[0] == 0 && dyn[4] == 40 && dyn[7] == 0) begin
            $display("PASS: resize larger preserves old values");
            pass_count++;
        end else begin
            $display("FAIL: resize larger - size=%0d, dyn[4]=%0d", dyn.size(), dyn[4]);
            fail_count++;
        end

        // Test 4: resize smaller
        dyn = new[3](dyn);
        if (dyn.size() == 3 && dyn[0] == 0 && dyn[1] == 10 && dyn[2] == 20) begin
            $display("PASS: resize smaller truncates correctly");
            pass_count++;
        end else begin
            $display("FAIL: resize smaller - size=%0d", dyn.size());
            fail_count++;
        end

        // Test 5: delete
        dyn.delete();
        if (dyn.size() == 0) begin
            $display("PASS: delete clears the array");
            pass_count++;
        end else begin
            $display("FAIL: delete - expected size 0, got %0d", dyn.size());
            fail_count++;
        end

        // Test 6: copy constructor
        dyn = new[4];
        foreach (dyn[i]) dyn[i] = i + 100;
        dyn2 = new[dyn.size()](dyn);
        if (dyn2.size() == 4 && dyn2[0] == 100 && dyn2[3] == 103) begin
            $display("PASS: copy constructor works");
            pass_count++;
        end else begin
            $display("FAIL: copy constructor - size=%0d, dyn2[0]=%0d", dyn2.size(), dyn2[0]);
            fail_count++;
        end

        // Summary
        $display("Dynamic resize test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All dynamic array tests passed");
        $finish;
    end
endmodule
