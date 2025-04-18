library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


-- Lab 4
entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(15 downto 0);
        btnU    :   in std_logic; -- master_reset
        btnL    :   in std_logic; -- clk_reset
        btnR    :   in std_logic; -- fsm_reset
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is

    -- signal declarations
    --updown=0, stop = 1
    --resetMaster = 0, reset clk = 1, reset FSM = 2
    
    signal w_floor1 :std_logic_vector (3 downto 0);
    signal w_floor2 :std_logic_vector (3 downto 0);

    signal w_btnL :std_logic;--clock
    signal w_btnU :std_logic;--master

    signal w_btnR :std_logic;--fsm
    signal w_reset : std_logic;
    signal w_reset2 : std_logic;

    signal w_clk :std_logic;
    
    
   signal w_seg1 : std_logic_vector (6 downto 0);
   signal w_seg2 : std_logic_vector (6 downto 0);
   signal w_reset_2 : std_logic;
   signal w_resfsm_clk : std_logic;
   signal w_tdm : std_logic;
   
    
    
    
    
    
  
	-- component declarations
    component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
    
    component elevator_controller_fsm is
		Port (
            i_clk        : in  STD_LOGIC;
            i_reset      : in  STD_LOGIC;
            is_stopped   : in  STD_LOGIC;
            go_up_down   : in  STD_LOGIC;
            o_floor : out STD_LOGIC_VECTOR (3 downto 0)		   
		 );
	end component elevator_controller_fsm;
	
	component TDM4 is
		generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	   );
    end component TDM4;
     
	component clock_divider is
        generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port ( 	i_clk    : in std_logic;
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
    end component clock_divider;
    
 
	
begin
	-- PORT MAPS ----------------------------------------
	w_reset_2 <= w_btnR or w_btnU;
	reset_fsm_clk <= w_btnL or w_btnU;

    
	elev_cont_fsm_inst : elevator_controller_fsm
	port map(
	
	i_clk      => w_clk,
    i_reset    => w_resfsm_clk,
    is_stopped => sw(0),
    go_up_down => sw(1),
    o_floor    => w_floor1
  
	);
	
	elev_cont_fsm_inst2 : elevator_controller_fsm
	port map(
	
	i_clk      => w_clk,
    i_reset    => w_resfsm_clk,
    is_stopped => sw(15),
    go_up_down => sw(14),
    o_floor    => w_floor2
    );
	
	
	clk_ist : clock_divider
	generic map (k_DIV => 25000000)
	port map(
	
	
	i_clk => clk,
	o_clk => w_clk,
	i_reset => w_reset_2
	);
	
	clk_ist2 : clock_divider
	generic map (k_DIV => 50000)
	port map(
	
	i_clk => clk,
	o_clk => w_tdm,
	i_reset => w_reset_2
	);
	
	
	seven_seg_inst : sevenseg_decoder
	port map(
	   i_Hex => w_floor1,
	   o_seg_n => w_seg1
	);
	
	seven_seg_inst2 : sevenseg_decoder
	port map(
	   i_Hex => w_floor2,
	   o_seg_n => w_seg2
    );
	
	
	TDM4_inst : TDM4
	generic map (k_WIDTH => 7)
	port map(
	i_clk => w_tdm,
	i_reset => btnU,
	i_D0 => w_seg1,
	i_D1 => w_seg2,
	i_D2 => "0001110",
	i_D3 => "0001110",
	o_data => seg,
	o_sel => an
	
	
	);
	
	
	
	

	
	
    
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	-- LED 15 gets the FSM slow clock signal. The rest are grounded.
	
	-- leave unused switches UNCONNECTED. Ignore any warnings this causes.
	
	-- reset signals
	
end top_basys3_arch;
