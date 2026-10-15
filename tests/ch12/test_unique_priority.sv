/*
:name: test_unique_priority
:description: unique/priority case/if
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3 12.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_priority.expected
*/
// IEEE 1800-2023 Section 12.5.3: unique/priority case/if
module test_unique_priority;
    int sel, result;

    int fails = 0;


    initial begin
        // unique case
        sel = 2;
        unique case (sel)
            1: result = 10;
            2: result = 20;
            3: result = 30;
        endcase
        if (result == 20)
            $display("PASS: unique case");
        else
            begin fails++; $display("FAIL: unique = %0d", result); end

        // priority case
        sel = 1;
        priority case (sel)
            1: result = 100;
            2: result = 200;
            default: result = 0;
        endcase
        if (result == 100)
            $display("PASS: priority case");
        else
            begin fails++; $display("FAIL: priority = %0d", result); end

        // unique if
        sel = 5;
        unique if (sel == 3)
            result = 1;
        else if (sel == 5)
            result = 2;
        else if (sel == 7)
            result = 3;
        if (result == 2)
            $display("PASS: unique if");
        else
            begin fails++; $display("FAIL: unique if = %0d", result); end

        // priority if
        sel = 10;
        priority if (sel > 15)
            result = 50;
        else if (sel > 5)
            result = 60;
        else
            result = 70;
        if (result == 60)
            $display("PASS: priority if");
        else
            begin fails++; $display("FAIL: priority if = %0d", result); end

        if (fails == 0) $display("TEST PASSED: unique/priority tests completed");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
