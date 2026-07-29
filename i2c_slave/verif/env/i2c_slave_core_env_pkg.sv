

package i2c_slave_core_env_pkg;

    `include "i2c_slave_core_env_config.svh"
    `include "i2c_slave_core_env.svh"

    typedef enum int { 
        CLK_I2C_SLAVE_CORE,
        _CLK_COUNT
    } clk_id_t;

endpackage