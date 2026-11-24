  // This flag persists outside simulator state across restart and reset.
  function automatic bit first_restore_request();
    int flag;
    flag = $fopen("restore-requested.flag", "r");
    if (flag != 0) begin
      $fclose(flag);
      return 0;
    end
    flag = $fopen("restore-requested.flag", "w");
    if (flag == 0) $fatal(1, "cannot record restore request");
    $fclose(flag);
    return 1;
  endfunction
