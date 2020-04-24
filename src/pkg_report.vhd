library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;



package pkg_report is

constant ID_LOG : string := "log";
constant ID_SIM : string := "sim";
constant ID_RST : string := "rst";
constant ID_CLK : string := "clk";


file report_file: text open write_mode is "report.log";

type severity_t is (info, note, warning, error, failure);
shared variable report_threshold: severity_t := info;


procedure report_init (
  constant f: in string := "report.log"
);


procedure report_log (
  constant id:  in string;
  constant sev: in severity_t;
  constant msg: in string
);


procedure report_assert (
  constant id:  in string;
  constant sev: in severity_t;
  constant msg: in string;
  constant cnd: in boolean
);

end package pkg_report;



package body pkg_report is

procedure report_init (
  constant f: in string := "report.log"
) is
  variable status: file_open_status;
begin
  report_log(ID_SIM, info, "Logging to file " & f);
  file_close(report_file);
  file_open(status, report_file, f, write_mode);
  assert status = open_ok report "Error opening report file." severity error;
  report file_open_status'image(status) severity note;
end procedure report_init;


procedure report_log (
  constant id:  in string;
  constant sev: in severity_t;
  constant msg: in string
) is
  variable l: line;
begin
  if severity_t'pos(sev) >= severity_t'pos(report_threshold) then
    write(l, time'image(now) & " " & id & " " & severity_t'image(sev) & ": " & msg);
    writeline(report_file, l);
  end if;
end procedure report_log;


procedure report_assert (
  constant id:  in string;
  constant sev: in severity_t;
  constant msg: in string;
  constant cnd: in boolean
) is
begin
  if not cnd then
    report_log(id, sev, msg);
  end if;
end procedure report_assert;

end package body pkg_report;