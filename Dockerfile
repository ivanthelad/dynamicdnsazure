#FROM ubuntu:16.04
FROM azuresdk/azure-cli-python
#RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | tee /etc/apt/sources.list.d/azure-cli.list 
#RUN apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
#RUN apt-get install  -y --no-install-recommends apt-transport-https  
#RUN apt-get update 
ENV SUBSCRIPTION=""
ENV SP_ID=""
ENV SP_PASSWORD=""
#RUN apt-get install azure-cli -y 
RUN mkdir /dynadns
WORKDIR /dynadns
COPY start.sh /dynadns/start.sh
COPY resolv.conf.upstream.tmp /dynadns/resolv.conf.upstream.tmp
COPY dnsmasq.conf.tmp /dynadns/dnsmasq.conf.tmp
RUN chmod 777 /dynadns/start.sh
RUN apk --no-cache add dnsmasq
EXPOSE 53 53/udp
#ENTRYPOINT ["dnsmasq", "-k"]
ENTRYPOINT ["/dynadns/start.sh"]





