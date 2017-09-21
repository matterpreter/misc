#!/usr/bin/env python
from boofuzz import *

def main():
    session = Session(
        target=Target(
            connection=SocketConnection("12.34.56.78", 21, proto='tcp')))

    #Authentication
    s_initialize("user")
    s_string("USER")
    s_delim(" ")
    s_string("myusername")
    s_static("\r\n")

    s_initialize("pass")
    s_string("PASS")
    s_delim(" ")
    s_string("mypassword")
    s_static("\r\n")
    
    #Functions
    s_initialize("dir")
    s_string("DIR")
    s_delim(" ")
    s_string("AAAA")
    s_static("\r\n")

    s_initialize("get")
    s_string("GET")
    s_delim(" ")
    s_string("AAAA")
    s_static("\r\n")

    s_initialize("recv")
    s_string("RECV")
    s_delim(" ")
    s_string("AAAA")
    s_static("\r\n")

    s_initialize("site")
    s_string("SITE")
    s_delim(" ")
    s_string("AAAA")
    s_static("\r\n")

    s_initialize("size")
    s_string("SIZE")
    s_delim(" ")
    s_string("AAAA")
    s_static("\r\n")   
              
    #Setup
    session.connect(s_get("user"))
    session.connect(s_get("user"), s_get("pass"))
    session.connect(s_get("pass"), s_get("dir"))
    session.connect(s_get("pass"), s_get("get"))
    session.connect(s_get("pass"), s_get("recv"))
    session.connect(s_get("pass"), s_get("site"))
    session.connect(s_get("pass"), s_get("size"))
    
    #Fire up the fuzzer!
    session.fuzz()

if __name__ == "__main__":
    main()
