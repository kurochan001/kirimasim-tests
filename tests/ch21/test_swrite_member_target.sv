/*
:name: test_swrite_member_target
:description: $swrite/$sprintf to member variable targets
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 8.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_swrite_member_target.expected
*/
// IEEE 1800-2023 §21.3.3: $swrite/$sprintf to member variable targets
module test_swrite_member_target;

    class Container;
        string label;
        function new();
            label = "";
        endfunction
    endclass

    string result;
    int pass_count;
    int fail_count;
    int test_count;

    initial begin
        Container obj;
        pass_count = 0;
        fail_count = 0;
        test_count = 0;

        // Test 1: $swrite to simple variable (baseline)
        $swrite(result, "hello %0d", 42);
        test_count = test_count + 1;
        if (result == "hello 42") pass_count = pass_count + 1;
        else begin fail_count = fail_count + 1; $display("FAIL: simple_swrite got '%s'", result); end

        // Test 2: $swrite to class member
        obj = new();
        $swrite(obj.label, "object_%0d", 3);
        test_count = test_count + 1;
        if (obj.label == "object_3") pass_count = pass_count + 1;
        else begin fail_count = fail_count + 1; $display("FAIL: class_member got '%s'", obj.label); end

        // Summary
        $display("=== swrite Member Target Tests ===");
        $display("Tests: %0d, Pass: %0d, Fail: %0d", test_count, pass_count, fail_count);

        if (fail_count == 0)
            $display("PASS: All %0d tests passed", test_count);
        else
            $display("FAIL: %0d tests failed", fail_count);

        $finish;
    end
endmodule
