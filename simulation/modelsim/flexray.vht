library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.flexray;

entity flexray_tb is
end flexray_tb;

architecture tb of flexray_tb is
  component flexray_rx is
    port (
      clk   : in  std_ulogic;
      rst   : in  std_ulogic;
      rx    : in  std_ulogic;
      msg   : out work.flexray.message;
      ready : out std_ulogic);
  end component flexray_rx;

  component flexray_generator is
    port (channel_0 : out std_ulogic);
  end component flexray_generator;

  constant tb_clk_period : time       := 12.5 ns;  -- 8x bitrate 80 Mhz
  signal tb_clk          : std_ulogic := '0';

  signal rst : std_ulogic := '1';

  signal debug     : std_ulogic;
  signal channel_0 : std_ulogic;
  signal ready     : std_ulogic;
  signal msg       : work.flexray.message;

begin
  rx      : flexray_rx port map(clk              => tb_clk, rst => rst, rx => channel_0, msg => msg, ready => ready);
  la_dump : flexray_generator port map(channel_0 => channel_0);

  clock_proc : process
  begin
    -- Perform reset
    wait for tb_clk_period / 2;
    tb_clk <= '1';
    wait for tb_clk_period / 2;
    rst    <= '0';
    tb_clk <= '0';

    for i in 1 to 8 loop
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
    end loop;

    for i in 1 to 3 * 256 * 8 loop
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
    end loop;
    wait;
  end process;
end tb;
