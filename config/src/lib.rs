#![allow(unused)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

// pub mod web {

    /// IP address
    pub const ip: &'static str = "127.0.0.1";
    /// IP port
    pub const port: u16 = 17878;

    /// socket connect/bind string
    pub const bind: &'static str = const_format::formatcp!("{}:{}", ip, port);

    /// full URL access address
    pub const url: &'static str = const_format::formatcp!("http://{bind}");

// }
