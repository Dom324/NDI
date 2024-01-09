----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    14:22:33 10/18/2023
-- Design Name:
-- Module Name:    SPI_IF - Behavioral
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

entity SPI_IF is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;

        -- SPI
        CS_b : in  STD_LOGIC;
        SCLK : in  STD_LOGIC;
        MOSI : in  STD_LOGIC;
        MISO : out  STD_LOGIC;

        -- idk
        fr_start    : out  STD_LOGIC;
        fr_end      : out  STD_LOGIC;
        fr_err      : out  STD_LOGIC;
        data_out    : out  STD_LOGIC_VECTOR (15 downto 0);

        data_in : in  STD_LOGIC_VECTOR (15 downto 0);
        load_data : in  STD_LOGIC

    );
end SPI_IF;

architecture Behavioral of SPI_IF is

    signal r_CS1 : STD_LOGIC;
    signal r_CS2 : STD_LOGIC;

    signal r_SCLK1 : STD_LOGIC;
    signal r_SCLK2 : STD_LOGIC;

    signal r_MOSI1 : STD_LOGIC;
    signal r_MOSI2 : STD_LOGIC;

    -- Registers for r/f edge detection
    signal r_old_CS : STD_LOGIC;
    signal r_old_SCLK : STD_LOGIC;

    signal s_CS_falling : STD_LOGIC;
    signal s_CS_rising : STD_LOGIC;

    signal s_SCLK_falling : STD_LOGIC;
    signal s_SCLK_rising : STD_LOGIC;

    -- frame check
    signal fr_length_data : unsigned (4 downto 0);
    signal fr_length_reg : unsigned (4 downto 0);

    component deser
    port (
        stream : in  STD_LOGIC;
        shift_en : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        clk : in  STD_LOGIC;
        data : out  STD_LOGIC_VECTOR (15 downto 0)
    );
    end component deser;

    component ser
    port (
        data : in  STD_LOGIC_VECTOR (15 downto 0);
        load_en : in  STD_LOGIC;
        shift_en : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        clk : in  STD_LOGIC;
        stream : out  STD_LOGIC
    );
    end component ser;

begin

    process(clk, rst) is
        begin
        if rst = '1' then
            r_CS1 <= '0';
            r_CS2 <= '0';

            r_SCLK1 <= '0';
            r_SCLK2 <= '0';

            r_MOSI1 <= '0';
            r_MOSI2 <= '0';

            r_old_CS <= '0';
            r_old_SCLK <= '0';

            fr_length_reg <= "00000";
        elsif rising_edge(clk) then
            r_CS1 <= CS_b;
            r_CS2 <= r_CS1;

            r_SCLK1 <= SCLK;
            r_SCLK2 <= r_SCLK1;

            r_MOSI1 <= MOSI;
            r_MOSI2 <= r_MOSI1;

            r_old_CS <= r_CS2;
            r_old_SCLK <= r_SCLK2;

            fr_length_reg <= fr_length_data;
        end if;
    end process;

    deserializer : deser
        port map (
            stream => r_MOSI2,
            shift_en => s_SCLK_rising,
            rst => rst,
            clk => clk,
            data => data_out
        );

    serializer : ser
        port map (
            stream => MISO,
            shift_en => s_SCLK_falling,
            load_en => load_data,
            rst => rst,
            clk => clk,
            data => data_in
        );

    s_CS_falling <= not r_CS2 and r_old_CS;
    s_CS_rising <= r_CS2 and not r_old_CS;

    s_SCLK_falling <= not r_SCLK2 and r_old_SCLK;
    s_SCLK_rising <= r_SCLK2 and not r_old_SCLK;

    fr_start <= s_CS_falling;
    fr_end <= s_CS_rising;

    process(s_SCLK_falling, s_CS_rising, fr_length_reg, s_CS_falling) is
        begin
        if s_CS_falling = '1' then
            fr_length_data <= "00000";
        elsif s_SCLK_falling = '1' then
            fr_length_data <= fr_length_reg + "00001";
        else
            fr_length_data <= fr_length_reg;
        end if;

        if ((s_CS_rising = '1') and (fr_length_reg /= 15)) or ((fr_length_reg >= 16) and (s_CS_rising = '0')) then
            fr_err <= '1';
        else
            fr_err <= '0';
        end if;
    end process;


end Behavioral;

