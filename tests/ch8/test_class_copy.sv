/*
:name: test_class_copy
:description: Class Copy (§8.13)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_copy.expected
*/
// IEEE 1800-2023 Class Copy (§8.13)
// Tests shallow copy behavior

class DataPacket;
    int id;
    string name;
    int data[];

    function new(int i, string n);
        id = i;
        name = n;
        data = new[3];
        foreach (data[j]) data[j] = j * 10;
    endfunction
endclass

module test_class_copy;
    initial begin
        DataPacket p1, p2;
        static int pass_count = 0;
        static int fail_count = 0;

        // Create original packet
        p1 = new(1, "packet1");

        // Test 1: Shallow copy
        p2 = new p1;

        if (p2.id == 1 && p2.name == "packet1") begin
            $display("PASS: Shallow copy copied fields");
            pass_count++;
        end else begin
            $display("FAIL: Shallow copy did not copy fields");
            fail_count++;
        end

        // Test 2: Modify copy doesn't affect original (for scalar types)
        p2.id = 2;
        p2.name = "packet2";

        if (p1.id == 1 && p1.name == "packet1") begin
            $display("PASS: Modifying copy doesn't affect original scalars");
            pass_count++;
        end else begin
            $display("FAIL: Original was affected by copy modification");
            fail_count++;
        end

        // Test 3: Different object handles
        if (p1 != p2) begin
            $display("PASS: p1 and p2 are different objects");
            pass_count++;
        end else begin
            $display("FAIL: p1 and p2 should be different objects");
            fail_count++;
        end

        // Test 4: A shallow copy copies variables, including a dynamic array,
        // and only object handles are shared (8.12).
        p2.data[0] = 99;
        if (p1.data[0] == 0 && p2.data[0] == 99) begin
            $display("PASS: Object creation and copy verified");
            pass_count++;
        end else begin
            $display("FAIL: dynamic array member shared: p1.data[0]=%0d", p1.data[0]);
            fail_count++;
        end

        $display("");
        $display("=== Class Copy Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
