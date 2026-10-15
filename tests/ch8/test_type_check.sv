/*
:name: test_type_check
:description: Type Checking Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_check.expected
*/
// IEEE 1800-2023 Section 6.24 - Type Checking Tests
module test_type_check;
    int pass_count = 0;
    int fail_count = 0;

    class Base;
        int id;
        function new(int i);
            id = i;
        endfunction
    endclass

    class Derived extends Base;
        int extra;
        function new(int i, int e);
            super.new(i);
            extra = e;
        endfunction
    endclass

    initial begin
        Base b;
        Derived d;
        int success;

        $display("=== IEEE 1800-2023 Type Checking Tests ===");

        $display("Test 1: Create base");
        b = new(1);
        if (b != null && b.id == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Create derived");
        d = new(2, 10);
        if (d != null && d.id == 2 && d.extra == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Assign derived to base");
        b = d;
        if (b != null && b.id == 2) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Cast back to derived");
        success = $cast(d, b);
        if (success && d.extra == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: New base");
        b = new(5);
        if (b.id == 5) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Cast base to derived fails");
        success = $cast(d, b);
        if (success == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Variable check");
        d = new(7, 70);
        if (d.id == 7 && d.extra == 70) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Non-null check");
        d = new(8, 80);
        if (d != null) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
