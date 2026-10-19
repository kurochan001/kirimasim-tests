/*
:name: test_comb_systask_string_format
:description: Test: System task string/format functions coverage
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.3.4.3 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_systask_string_format.expected
*/
// Test: System task string/format functions
module test_comb_systask_string_format;
    string s1, s2;
    integer i1, code;
    real r1;
    int pass_count;
    logic [31:0] val;

    initial begin
        pass_count = 0;

        // $sformatf with various format specifiers
        s1 = $sformatf("dec=%0d hex=%0h bin=%0b oct=%0o", 42, 42, 42, 42);
        $display("Format: %s", s1);
        pass_count++;

        // $sformatf with string
        s1 = $sformatf("name=%s len=%0d", "hello", 5);
        $display("String format: %s", s1);
        pass_count++;

        // $sformatf with real
        s1 = $sformatf("real=%f sci=%e", 3.14, 3.14);
        $display("Real format: %s", s1);
        pass_count++;

        // $sformatf with time
        s1 = $sformatf("time=%0d", $time);
        $display("Time format: %s", s1);
        pass_count++;

        // $sscanf
        code = $sscanf("123 456", "%d %d", i1, val);
        if (code == 2 && i1 == 123 && val == 456) pass_count++;
        else $error("sscanf failed: code=%0d i1=%0d val=%0d", code, i1, val);

        code = $sscanf("FF", "%h", val);
        if (code == 1 && val == 255) pass_count++;
        else $error("sscanf hex failed: val=%0d", val);

        code = $sscanf("3.14", "%f", r1);
        if (code == 1) pass_count++;

        // String methods
        s1 = "Hello World";
        i1 = s1.len();
        if (i1 == 11) pass_count++;

        s2 = s1.substr(0, 4);
        if (s2 == "Hello") pass_count++;

        s1 = s1.toupper();
        if (s1 == "HELLO WORLD") pass_count++;

        s1 = s1.tolower();
        if (s1 == "hello world") pass_count++;

        // String comparison
        s1 = "abc";
        s2 = "def";
        if (s1 < s2) pass_count++;
        if (s1 != s2) pass_count++;

        // $sformatf with width specifiers
        s1 = $sformatf("|%10d|", 42);
        $display("Width format: %s", s1);
        pass_count++;


        // $write / $writeh / $writeb / $writeo
        $write("write: %0d ", 100);
        $writeh("writeh: %0h ", 255);
        $writeb("writeb: %0b ", 8'b10101010);
        $writeo("writeo: %0o\n", 8'o77);
        pass_count++;

        $display("pass_count = %0d", pass_count);
        if (pass_count == 15)
            $display("PASS: test_comb_systask_string_format");
        else
            $display("FAIL: test_comb_systask_string_format (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
