library ieee;
use ieee.std_logic_1164.all;

entity divider_tb is
end divider_tb;

architecture tb of divider_tb is
  component divider is
    generic (
      divides : integer);
    port (
      clk : in  std_ulogic;
      rst : in  std_ulogic;
      o   : out std_ulogic);
  end component divider;

  constant divides       : integer    := 8;
  constant tb_clk_period : time       := 100 us;
  signal tb_clk          : std_ulogic := '0';
  signal tb_rst          : std_ulogic := '0';
  signal div_out         : std_ulogic;

begin
  dut : divider generic map (divides => divides) port map(clk => tb_clk, o => div_out, rst => tb_rst);

  clock_proc : process
  begin
    for i in 1 to 3 * divides loop
      tb_clk <= not tb_clk;
      wait for tb_clk_period;
      tb_clk <= not tb_clk;
      wait for tb_clk_period;
    end loop;
    wait;
  end process;

  test_proc : process
  begin
    wait for tb_clk_period;
    assert div_out = '0' severity failure;
    wait for tb_clk_period * divides;
    assert div_out = '1' severity failure;

    wait;

  end process;
end tb;
