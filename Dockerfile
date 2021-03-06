FROM alpine as builder

ARG SPI_SPEED=2000000

RUN apk add --no-cache git gcc make musl-dev linux-headers \
	&& git clone https://github.com/filoozom/packet_forwarder.git \
	&& git clone https://github.com/Lora-net/lora_gateway \
	&& cd lora_gateway \
	&& sed -i 's/^#define SPI_SPEED\( *\)[^ ]*$/#define SPI_SPEED\1'"$SPI_SPEED"'/g' libloragw/src/loragw_spi.native.c \
	&& make \
	&& cd ../packet_forwarder/lora_pkt_fwd \
	&& make \
	&& chmod +x lora_pkt_fwd

FROM scratch

COPY --from=builder /packet_forwarder/lora_pkt_fwd/lora_pkt_fwd /app/forwarder

ENTRYPOINT ["/app/forwarder"]
