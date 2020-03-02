library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flexray_intercept_tb is
end flexray_intercept_tb;

architecture tb of flexray_intercept_tb is
  component flexray_interceptor is
    port (
      clk      : in  std_ulogic;
      rst      : in  std_ulogic;
      rx_0     : in  std_ulogic;
      tx_0     : out std_ulogic;
      tx_en_0  : out std_ulogic;
      rx_1     : in  std_ulogic;
      tx_1     : out std_ulogic;
      tx_en_1  : out std_ulogic;
      rx       : out std_ulogic;
      tx       : in  std_ulogic;
      override : in  std_ulogic);
  end component flexray_interceptor;

  component flexray_syn_packet is
    port (
      clk : in  std_ulogic;
      rst : in  std_ulogic;
      o   : out std_ulogic);
  end component flexray_syn_packet;

  component flexray_torque_intercept is
    port (
      clk      : in  std_ulogic;
      rst      : in  std_ulogic;
      rx       : in  std_ulogic;
      torque   : in  std_ulogic_vector(7 downto 0);
      sign     : in  std_ulogic;
      enable   : in  std_ulogic;
      tx       : out std_ulogic;
      override : out std_ulogic);
  end component flexray_torque_intercept;


  component flexray_generator is
    port (channel_0 : out std_ulogic);
  end component flexray_generator;

  constant tb_clk_period : time       := 12.5 ns;  -- 8x bitrate 80 Mhz
  signal tb_clk          : std_ulogic := '0';

  signal rst : std_ulogic := '1';

  signal channel_0 : std_ulogic;

  signal rx : std_ulogic;
  signal tx : std_ulogic;
  signal override : std_ulogic;

  signal rx_0    : std_ulogic;
  signal tx_0    : std_ulogic;
  signal tx_en_0 : std_ulogic;
  signal rx_1    : std_ulogic;
  signal tx_1    : std_ulogic;
  signal tx_en_1 : std_ulogic;

  signal torque   : std_ulogic_vector(7 downto 0);
  signal sign     : std_ulogic;
  signal enable   : std_ulogic;

begin
  dut : flexray_interceptor port map(clk => tb_clk, rst => rst,
                                     rx_0  => rx_0, tx_0 => tx_0, tx_en_0 => tx_en_0,
                                     rx_1  => rx_1, tx_1 => tx_1, tx_en_1 => tx_en_1,
                                     rx => rx, tx => tx, override => override);
  la_dump : flexray_generator port map(channel_0 => channel_0);
  -- la_dump : flexray_syn_packet port map(clk => tb_clk, rst => rst, o => channel_0);

  intercept : flexray_torque_intercept port map(clk => tb_clk, rst => rst, rx => rx, tx => tx, override => override,
                                                torque => torque, sign => sign, enable => enable);

  rx_1 <= channel_0;
  rx_0 <= '1';
  torque <= x"FF";
  enable <= '1';
  sign <= '1';

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

    for i in 1 to 20 * 50 * 3 * 256 * 8 loop
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
      tb_clk <= not tb_clk;
      wait for tb_clk_period / 2;
    end loop;
    wait;
  end process;
end tb;
