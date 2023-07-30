#![allow(unused)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

use std::io::{prelude::*, BufReader};
use std::net::{TcpListener, TcpStream};

fn main() {
    let listener = TcpListener::bind(config::web::bind).unwrap();
    println!("{}", config::web::url);
    for stream in listener.incoming() {
        let stream = stream.unwrap();
        handle(stream);
    }
}

fn handle(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let http_request: Vec<_> = buf_reader
        .lines()
        .map(|result| result.unwrap())
        .take_while(|line| !line.is_empty())
        .collect();

    let req = &http_request[0];

    println!("Request: {:#?}", req);
}
