FROM fedora:latest

COPY / /MyLinuxConfig/

WORKDIR /MyLinuxConfig

ENTRYPOINT ["./make"]
