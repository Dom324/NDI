----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    15:19:04 10/25/2023
-- Design Name:
-- Module Name:    Top - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;

        -- SPI
        CS_b : in  STD_LOGIC;
        SCLK : in  STD_LOGIC;
        MOSI : in  STD_LOGIC;
        MISO : out  STD_LOGIC
    );
end Top;

architecture Behavioral of Top is

    signal fr_start      : STD_LOGIC;
    signal fr_end        : STD_LOGIC;
    signal fr_err        : STD_LOGIC;
    signal data_out      : STD_LOGIC_VECTOR (15 downto 0);
    signal data_in       : STD_LOGIC_VECTOR (15 downto 0);
    signal load_data     : STD_LOGIC;
    signal we_result     : STD_LOGIC;
    signal we_data_fr1   : STD_LOGIC;
    signal we_data_fr2   : STD_LOGIC;
    signal data_fr       : STD_LOGIC_VECTOR (15 downto 0);
    signal add_res       : STD_LOGIC_VECTOR (15 downto 0);
    signal mul_res       : STD_LOGIC_VECTOR (15 downto 0);

component SPI_IF
    port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;

        -- SPI
        CS_b        : in  STD_LOGIC;
        SCLK        : in  STD_LOGIC;
        MOSI        : in  STD_LOGIC;
        MISO        : out STD_LOGIC;

        -- idk
        fr_start    : out STD_LOGIC;
        fr_end      : out STD_LOGIC;
        fr_err      : out STD_LOGIC;
        data_out    : out STD_LOGIC_VECTOR (15 downto 0);

        data_in     : in  STD_LOGIC_VECTOR (15 downto 0);
        load_data   : in  STD_LOGIC
    );
end component SPI_IF;

component pkt_ctrl
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        fr_start    : in  STD_LOGIC;
        fr_end      : in  STD_LOGIC;
        fr_err      : in  STD_LOGIC;
        data_out    : in  STD_LOGIC_VECTOR (15 downto 0);
        load_data   : out STD_LOGIC;
        data_in     : out STD_LOGIC_VECTOR (15 downto 0);
        we_result   : out STD_LOGIC;
        we_data_fr1 : out STD_LOGIC;
        we_data_fr2 : out STD_LOGIC;
        data_fr     : out STD_LOGIC_VECTOR (15 downto 0);
        add_res     : in  STD_LOGIC_VECTOR (15 downto 0);
        mul_res     : in  STD_LOGIC_VECTOR (15 downto 0)
    );
end component pkt_ctrl;

component alu
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR (15 downto 0);
        we_result   : in  STD_LOGIC;
        we_data_fr1 : in  STD_LOGIC;
        we_data_fr2 : in  STD_LOGIC;
        add_res     : out STD_LOGIC_VECTOR (15 downto 0);
        mul_res     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end component alu;

begin
SPI_interface : SPI_IF
    port map (
        clk => clk,
        rst => rst,

        -- SPI
        CS_b => CS_b,
        SCLK => SCLK,
        MOSI => MOSI,
        MISO => MISO,

        -- idk
        fr_start => fr_start,
        fr_end => fr_end,
        fr_err => fr_err,
        data_out => data_out,

        data_in => data_in,
        load_data => load_data
    );

pkt_control : pkt_ctrl
    port map (
        clk => clk,
        rst => rst,

        fr_start => fr_start,
        fr_end => fr_end,
        fr_err => fr_err,
        data_out => data_out,
        load_data => load_data,
        data_in => data_in,

        we_result => we_result,
        we_data_fr1 => we_data_fr1,
        we_data_fr2 => we_data_fr2,

        data_fr => data_fr,
        add_res => add_res,
        mul_res => mul_res
    );

aluu : alu
    port map (
        clk => clk,
        rst => rst,

        we_result => we_result,
        we_data_fr1 => we_data_fr1,
        we_data_fr2 => we_data_fr2,

        data_in => data_fr,
        add_res => add_res,
        mul_res => mul_res
    );

end Behavioral;

