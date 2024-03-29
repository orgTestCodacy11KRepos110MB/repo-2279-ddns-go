# build stage
FROM --platform=$BUILDPLATFORM golang:1.19-alpine AS builder

WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add git make tzdata \
    && go env -w GO111MODULE=on \
    && go env -w GOPROXY=https://goproxy.cn,direct \
    && GOOS=$TARGETOS GOARCH=$TARGETARCH make clean build

# final stage
FROM alpine
LABEL name=ddns-go
LABEL url=https://github.com/jeessy2/ddns-go

WORKDIR /app
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
ENV TZ=Asia/Shanghai
COPY --from=builder /app/ddns-go /app/ddns-go
EXPOSE 9876
ENTRYPOINT ["/app/ddns-go"]
CMD ["-l", ":9876", "-f", "300"]
