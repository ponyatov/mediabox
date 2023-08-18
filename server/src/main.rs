#![allow(unused)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

use std::io::{prelude::*, BufReader};
use std::net::{TcpListener, TcpStream};

fn main() {
    println!("{}", config::url);
    let listener = TcpListener::bind(config::bind).unwrap();
    for stream in listener.incoming() {
        let stream = stream.unwrap();
        handle(stream);
    }
}

#[macro_use]
extern crate lalrpop_util;

lalrpop_mod!(pub http);

fn handle(mut stream: TcpStream) {
    let buf_reader = BufReader::new(&mut stream);
    let buf_reader = BufReader::new(&mut stream);
    let req = buf_reader.lines().next().unwrap().unwrap();
    println!("{}", req);
    http::GETParser::new().parse(&mut stream, &req).unwrap();
}

pub fn serve(mut stream: &TcpStream, ctype: &[u8], data: &[u8]) {
    stream.write(OK_200).unwrap();
    stream.write(ctype).unwrap();
    stream.write(b"\n").unwrap();
    stream.write(data).unwrap();
}

const OK_200: &[u8] = b"HTTP 200 OK\n";
const TEXT_PLAIN: &[u8] = b"Content-Type: text/plain\n";
const TEXT_HTML: &[u8] = b"Content-Type: text/html\n";
const TEXT_CSS: &[u8] = b"Content-Type: text/css\n";
const IMAGE_PNG: &[u8] = b"Content-Type: image/png\n";

const APP_MANIFEST: &[u8] = b"application/manifest+json\n";
const MANIFEST_HEAD: &[u8] = b"<link rel=\"manifest\" href=\"/manifest\">";

const HTML_HEAD1: &[u8] = include_bytes!("../template/html.head1");
const HTML_HEAD2: &[u8] = include_bytes!("../template/html.head2");
const HTML_TAIL: &[u8] = include_bytes!("../template/html.tail");

const INDEX_HTML: &[u8] = include_bytes!("../template/index.html");
const ABOUT_HTML: &[u8] = include_bytes!("../static/about.html");

const LOGO_PNG: &[u8] = include_bytes!("../static/logo/512.png");
const LOGO_48: &[u8] = include_bytes!("../static/logo/48.png");
const LOGO_72: &[u8] = include_bytes!("../static/logo/72.png");
const LOGO_96: &[u8] = include_bytes!("../static/logo/96.png");
const LOGO_128: &[u8] = include_bytes!("../static/logo/128.png");
const LOGO_192: &[u8] = include_bytes!("../static/logo/192.png");
const LOGO_384: &[u8] = include_bytes!("../static/logo/384.png");
const LOGO_512: &[u8] = include_bytes!("../static/logo/512.png");
const CSS: &[u8] = include_bytes!("../static/css.css");
const MANIFEST: &[u8] = include_bytes!("../static/manifest");
