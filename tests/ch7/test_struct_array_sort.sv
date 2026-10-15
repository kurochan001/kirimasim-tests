/*
:name: test_struct_array_sort
:description: Corner Case: Struct Array Sorting
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2 7.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_array_sort.expected
*/
// Corner Case: Struct Array Sorting
// Tests sort/rsort on arrays of structures

module test_struct_array_sort;
    int pass_count = 0;
    int fail_count = 0;

    // Simple struct
    typedef struct {
        int id;
        int value;
    } record_t;

    initial begin
        record_t records[5];
        int ids[5];

        // Test 1: Initialize struct array
        records[0].id = 5; records[0].value = 50;
        records[1].id = 2; records[1].value = 20;
        records[2].id = 4; records[2].value = 40;
        records[3].id = 1; records[3].value = 10;
        records[4].id = 3; records[4].value = 30;
        pass_count++;

        // Test 2: Extract IDs to array
        foreach (records[i]) ids[i] = records[i].id;
        if (ids[0] == 5 && ids[3] == 1) pass_count++;
        else begin fail_count++; $display("FAIL: extract ids"); end

        // Test 3: Sort integer array
        ids.sort();
        if (ids[0] == 1 && ids[4] == 5) pass_count++;
        else begin fail_count++; $display("FAIL: sort int array"); end

        // Test 4: Reverse sort integer array
        ids.rsort();
        if (ids[0] == 5 && ids[4] == 1) pass_count++;
        else begin fail_count++; $display("FAIL: rsort int array"); end

        // Test 5: Sort struct array by field
        records.sort with (item.id);
        if (records[0].id == 1 && records[4].id == 5) pass_count++;
        else begin fail_count++; $display("FAIL: sort struct by id"); end

        // Test 6: Reverse sort struct array
        records.rsort with (item.id);
        if (records[0].id == 5 && records[4].id == 1) pass_count++;
        else begin fail_count++; $display("FAIL: rsort struct by id"); end

        // Test 7: Sort by value field
        records.sort with (item.value);
        if (records[0].value == 10 && records[4].value == 50) pass_count++;
        else begin fail_count++; $display("FAIL: sort by value"); end

        // Test 8: Struct field access after sort
        if (records[0].id == 1 && records[4].id == 5) pass_count++;
        else begin fail_count++; $display("FAIL: field after sort"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/8)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
