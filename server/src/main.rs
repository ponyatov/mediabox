#![allow(unused)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

use std::net::TcpListener;
fn main() {
    let listener = TcpListener::bind(config::web).unwrap();
    for stream in listener.incoming() {
        let stream = stream.unwrap();

        println!("Connection established!");
    }
}
